---
name: sudo-askpass
description: >
  Use when running commands that require sudo (root privileges) on this machine.
  This system uses sudo -A with bemenu askpass instead of standard TTY sudo.
  Triggers: any sudo, root, privilege escalation, package install, system config
  command that needs root.
---

# Sudo Askpass Skill

This machine has `sudo` configured with a Wayland-native askpass helper.

## How sudo works here

- **NEVER** use plain `sudo <command>` — it requires a TTY and will fail.
- **ALWAYS** use `sudo -A <command>` instead.
- `sudo -A` uses the program in `$SUDO_ASKPASS` (`~/.local/bin/askpass`) to show a
  `bemenu` popup window asking for the password on Wayland (Hyprland).
- The popup appears on the user's screen when the agent requests elevation.

## Important notes

- `SUDO_ASKPASS` is already exported in `~/.zshrc` pointing to `~/.local/bin/askpass`.
- The askpass script uses `bemenu --password` (Wayland-native, part of Omarchy).
- If running non-interactively (headless), you may need to set `$WAYLAND_DISPLAY` or
  fall back to `sudo -S` with password from env — but prefer `sudo -A` when the user
  is at the desktop.

## When to invoke

**ALWAYS use `sudo -A` instead of `sudo`** when the task requires root, including:
- Installing packages (`sudo -A pacman -S ...`)
- Writing to protected paths (`sudo -A tee ...`)
- Editing system files
- Running systemctl commands that need elevation
- Any other privileged operation
