# Espanso recovery on Omarchy

## Why recovery exists

Espanso’s Wayland input worker can lose an evdev device when a keyboard disconnects or re-enumerates. Its journal warning is explicit:

```text
Can't read from device /dev/input/eventN, this error usually means the device has been disconnected, removing from epoll.
```

Common triggers on this machine: docking/undocking between external and laptop keyboard, USB changes, and resume from sleep. Upstream documents restarting Espanso after connecting a keyboard as the current Wayland workaround; no general upstream hotplug fix was found during investigation.

## Current recovery behavior

`espanso-recovery-watch.service` runs `~/.local/bin/espanso_recovery_watch.py` in the Hyprland user session. It restarts Espanso only when both conditions hold:

1. Espanso logs the evdev-disconnect warning above.
2. The affected `/dev/input/eventN` is classified by udev as a keyboard (`ID_INPUT_KEYBOARD=1`) or was recently removed as one.

The watcher ignores Espanso’s virtual keyboard, remembers removed keyboard event paths for 10 seconds, waits 3 seconds for hotplug/resume events to settle, and applies a 15-second restart cooldown. A random USB device change alone does not restart Espanso. This is event-driven recovery, not a periodic health check; it cannot detect hangs that produce no matching warning.

The older broad `/dev/input/by-id` hotplug restart and unconditional resume restart are disabled. Keep them disabled: overlapping restarts caused duplicate worker termination during hotplug/resume.

## Diagnose and recover

```bash
systemctl --user status espanso.service espanso-recovery-watch.service
journalctl --user -u espanso.service -u espanso-recovery-watch.service --since '15 minutes ago'
```

Follow watcher decisions live:

```bash
journalctl --user -u espanso-recovery-watch.service -f
```

Expected watcher messages include `ignoring non-keyboard evdev loss` for unrelated input devices and `restarting Espanso after confirmed keyboard loss` for a recovery. If the warning is absent, the watcher intentionally does nothing; investigate Espanso/Wayland logs or restart manually:

```bash
systemctl --user restart espanso.service
```

To check udev classification for a currently attached input node:

```bash
udevadm info --query=property --name=/dev/input/eventN | grep '^ID_INPUT_KEYBOARD='
```

## Maintain

- Script: `.local/bin/espanso_recovery_watch.py`
- User unit: `.config/systemd/user/espanso-recovery-watch.service`
- User unit is enabled for `wayland-session@hyprland.desktop.target` on this machine. After restoring dotfiles on a fresh system, link files with `bash restore.sh`, then enable it with `systemctl --user enable --now espanso-recovery-watch.service`.
- After editing the unit, run `systemctl --user daemon-reload`; restart the watcher with `systemctl --user restart espanso-recovery-watch.service`.
- Keep the warning matcher aligned with Espanso’s journal text and keep keyboard classification narrow. Expand recovery only when logs show a different confirmed failure mode.
- Real physical hotplug/resume testing remains necessary after changes; parser/classification tests alone do not prove device recovery.

## Background

- [Espanso issue #2423: stops working after a while](https://github.com/espanso/espanso/issues/2423) — keyboard disconnect/reconnect reports.
- [Espanso Linux/Wayland installation notes](https://espanso.org/docs/install/linux/) — Wayland limitations and restart workaround.
- [Omarchy issue #88](https://github.com/omacom/omarchy/issues/88) — Omarchy’s XCompose preference; not an Espanso bug report.
- [Omarchy quick completions](https://learn.omacom.io/2/the-omarchy-manual/53/hotkeys#quick-completions) — XCompose alternative for simple fixed completions.
