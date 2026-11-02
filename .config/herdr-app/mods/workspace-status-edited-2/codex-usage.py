import json
import os
import select
import subprocess
import sys
import time


def read_response(process, request_id, buffer):
    deadline = time.monotonic() + 12
    while time.monotonic() < deadline:
        if b"\n" in buffer:
            line, buffer = buffer.split(b"\n", 1)
            try:
                message = json.loads(line)
            except (json.JSONDecodeError, UnicodeDecodeError):
                continue
            if message.get("id") == request_id:
                return message, buffer
            continue

        ready, _, _ = select.select(
            [process.stdout], [], [], max(0, deadline - time.monotonic())
        )
        if not ready:
            break
        chunk = os.read(process.stdout.fileno(), 65536)
        if not chunk:
            break
        buffer += chunk

    raise RuntimeError("Codex app-server timed out")


def request(process, request_id, method, params, buffer):
    message = {"id": request_id, "method": method, "params": params}
    process.stdin.write((json.dumps(message) + "\n").encode())
    process.stdin.flush()
    return read_response(process, request_id, buffer)


def quota_window(window, expected_minutes):
    if not isinstance(window, dict) or window.get("windowDurationMins") != expected_minutes:
        return None
    used = window.get("usedPercent")
    if not isinstance(used, (int, float)):
        return None
    return {
        "usedPercent": max(0, min(100, used)),
        "windowDurationMins": expected_minutes,
        "resetsAt": window.get("resetsAt"),
    }


def main():
    process = subprocess.Popen(
        ["codex", "app-server", "--stdio"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    buffer = b""
    try:
        initialized, buffer = request(
            process,
            1,
            "initialize",
            {
                "clientInfo": {
                    "name": "herdr-workspace-status",
                    "title": "Herdr status bar",
                    "version": "1",
                },
                "capabilities": None,
            },
            buffer,
        )
        if "error" in initialized:
            raise RuntimeError("Codex initialization failed")

        process.stdin.write(b'{"method":"initialized","params":{}}\n')
        process.stdin.flush()
        result, buffer = request(
            process,
            2,
            "account/rateLimits/read",
            {"excludeResetCreditDetails": True},
            buffer,
        )
        if "error" in result:
            raise RuntimeError("Codex usage request failed")

        snapshot = result.get("result", {})
        limits = snapshot.get("rateLimitsByLimitId") or {}
        codex = limits.get("codex") or snapshot.get("rateLimits") or {}
        primary = codex.get("primary") or {}
        secondary = codex.get("secondary") or {}
        print(
            json.dumps(
                {
                    "fiveHour": quota_window(primary, 300)
                    or quota_window(secondary, 300),
                    "sevenDay": quota_window(primary, 10080)
                    or quota_window(secondary, 10080),
                },
                separators=(",", ":"),
            )
        )
    finally:
        try:
            process.stdin.close()
        except Exception:
            pass
        try:
            process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.exit(1)
