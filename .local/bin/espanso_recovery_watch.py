#!/usr/bin/env python3
"""Restart Espanso only after it logs a lost physical keyboard event device."""

from __future__ import annotations

import glob
import queue
import re
import signal
import subprocess
import sys
import threading
import time
from pathlib import Path

WARNING = re.compile(
    r"Can't read from device (?P<device>/dev/input/event\d+), "
    r"this error usually means the device has been disconnected, removing from epoll\."
)
DEBOUNCE_SECONDS = 3.0
REMOVED_DEVICE_TTL = 10.0
RESTART_COOLDOWN = 15.0


def parse_warning_device(line: str) -> str | None:
    match = WARNING.search(line)
    return match.group("device") if match else None


def should_recover(
    device: str,
    keyboards: set[str],
    recently_removed: dict[str, float],
    now: float,
) -> bool:
    return device in keyboards or recently_removed.get(device, 0.0) > now


class Debouncer:
    def __init__(self, delay: float = DEBOUNCE_SECONDS) -> None:
        self.delay = delay
        self.deadline: float | None = None

    def note(self, now: float) -> None:
        self.deadline = now + self.delay

    def pop_due(self, now: float) -> bool:
        if self.deadline is None or now < self.deadline:
            return False
        self.deadline = None
        return True


def parse_properties(block: list[str]) -> dict[str, str]:
    properties: dict[str, str] = {}
    for line in block:
        if "=" in line:
            key, value = line.split("=", 1)
            properties[key] = value.strip().strip('"')
    return properties


def is_espanso_virtual(device: str) -> bool:
    name_path = Path("/sys/class/input") / Path(device).name / "device/name"
    try:
        return "espanso" in name_path.read_text().strip().lower()
    except OSError:
        return False


class KeyboardDevices:
    def __init__(self) -> None:
        self.current: set[str] = set()
        self.removed: dict[str, float] = {}
        for device in glob.glob("/dev/input/event*"):
            result = subprocess.run(
                ["udevadm", "info", "--query=property", f"--name={device}"],
                capture_output=True,
                text=True,
                timeout=2,
                check=False,
            )
            properties = parse_properties(result.stdout.splitlines())
            if (
                properties.get("ID_INPUT_KEYBOARD") == "1"
                and not is_espanso_virtual(device)
            ):
                self.current.add(device)

    def update(self, properties: dict[str, str], now: float) -> None:
        device = properties.get("DEVNAME", "")
        if not re.fullmatch(r"/dev/input/event\d+", device):
            return

        action = properties.get("ACTION", "")
        is_keyboard = properties.get("ID_INPUT_KEYBOARD") == "1"
        is_virtual = is_espanso_virtual(device)

        if action == "remove":
            if device in self.current or (is_keyboard and not is_virtual):
                self.removed[device] = now + REMOVED_DEVICE_TTL
            self.current.discard(device)
        elif action in {"add", "change", "bind", "move"}:
            if is_keyboard and not is_virtual:
                self.current.add(device)
            elif "ID_INPUT_KEYBOARD" in properties or action == "add" or is_virtual:
                self.current.discard(device)

        self.removed = {
            path: expires for path, expires in self.removed.items() if expires > now
        }

    def matches(self, device: str, now: float) -> bool:
        return should_recover(device, self.current, self.removed, now)


def forward_lines(
    stream, source: str, messages: queue.Queue[tuple[str, str | None]]
) -> None:
    for line in stream:
        messages.put((source, line.rstrip("\n")))
    messages.put((source, None))


def stop_process(process: subprocess.Popen[str] | None) -> None:
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=2)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=2)


def run() -> int:
    stopping = False

    def request_stop(_signum: int, _frame: object) -> None:
        nonlocal stopping
        stopping = True

    signal.signal(signal.SIGTERM, request_stop)
    signal.signal(signal.SIGINT, request_stop)

    devices = KeyboardDevices()
    print(
        f"[espanso-recovery] watching Espanso warnings; known keyboards={len(devices.current)}",
        flush=True,
    )

    journal = subprocess.Popen(
        ["journalctl", "--user", "--follow", "--unit=espanso.service", "--output=cat", "--lines=0"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )
    udev = subprocess.Popen(
        ["udevadm", "monitor", "--udev", "--property", "--subsystem-match=input"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )
    assert journal.stdout is not None and udev.stdout is not None

    messages: queue.Queue[tuple[str, str | None]] = queue.Queue()
    for stream, source in ((journal.stdout, "journal"), (udev.stdout, "udev")):
        threading.Thread(
            target=forward_lines,
            args=(stream, source, messages),
            daemon=True,
        ).start()

    udev_block: list[str] = []
    debouncer = Debouncer()
    pending_devices: set[str] = set()
    recovery: subprocess.Popen[str] | None = None
    cooldown_until = 0.0

    try:
        while not stopping:
            now = time.monotonic()
            timeout = 1.0
            if debouncer.deadline is not None:
                timeout = min(timeout, max(0.0, debouncer.deadline - now))

            try:
                source, line = messages.get(timeout=timeout)
            except queue.Empty:
                source, line = "", ""

            now = time.monotonic()
            if line is None:
                print(f"[espanso-recovery] {source} monitor exited", flush=True)
                return 1

            if source == "journal":
                device = parse_warning_device(line)
                if device is not None:
                    if not devices.matches(device, now):
                        print(
                            f"[espanso-recovery] ignoring non-keyboard evdev loss: {device}",
                            flush=True,
                        )
                    elif recovery is None and now >= cooldown_until:
                        pending_devices.add(device)
                        debouncer.note(now)
                        print(
                            f"[espanso-recovery] Espanso lost keyboard device {device}; "
                            f"waiting {DEBOUNCE_SECONDS:g}s for events to settle",
                            flush=True,
                        )
            elif source == "udev":
                if line:
                    udev_block.append(line)
                elif udev_block:
                    properties = parse_properties(udev_block)
                    devices.update(properties, now)
                    if properties.get("ID_INPUT_KEYBOARD") == "1":
                        device = properties.get("DEVNAME", "")
                        if device in pending_devices:
                            debouncer.note(now)
                    udev_block.clear()

            if recovery is not None and recovery.poll() is not None:
                if recovery.returncode == 0:
                    print(
                        f"[espanso-recovery] restarted Espanso after keyboard loss: "
                        f"{', '.join(sorted(pending_devices))}",
                        flush=True,
                    )
                else:
                    print(
                        f"[espanso-recovery] systemctl restart failed: {recovery.returncode}",
                        flush=True,
                    )
                recovery = None
                pending_devices.clear()
                cooldown_until = now + RESTART_COOLDOWN

            if (
                recovery is None
                and now >= cooldown_until
                and messages.empty()
                and debouncer.pop_due(now)
            ):
                recovery = subprocess.Popen(
                    ["systemctl", "--user", "restart", "espanso.service"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    text=True,
                )
                print(
                    f"[espanso-recovery] restarting Espanso after confirmed keyboard loss: "
                    f"{', '.join(sorted(pending_devices))}",
                    flush=True,
                )

    finally:
        stop_process(recovery)
        stop_process(journal)
        stop_process(udev)

    return 0


if __name__ == "__main__":
    try:
        sys.exit(run())
    except Exception as exc:
        print(f"[espanso-recovery] fatal: {exc}", file=sys.stderr, flush=True)
        raise
