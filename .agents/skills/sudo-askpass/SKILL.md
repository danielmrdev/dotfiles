---
name: sudo-askpass
description: >
  Use when running commands that require sudo (root privileges) on this machine.
  This system uses sudo -A with bemenu askpass instead of standard TTY sudo.
  Triggers: any sudo, root, privilege escalation, package install, system config
  command that needs root.
---

# Sudo Askpass Skill

This machine has `sudo` configured with an Omarchy-theme-aware GTK3 askpass helper.

## How sudo works here

- **NEVER** use plain `sudo <command>` — it requires a TTY and will fail.
- **ALWAYS** use `sudo -A <command>` instead.
- `sudo -A` uses the program in `$SUDO_ASKPASS` (`~/.local/bin/askpass`) to show a
  GTK3 dialog using the current Omarchy theme colors.
- The dialog appears on the user's screen when the agent requests elevation.

## Important notes

- `SUDO_ASKPASS` is exported in `~/.zshrc` pointing to `~/.local/bin/askpass`.
- The script reads `~/.config/omarchy/current/theme/colors.toml` every time it runs.
- `lxqt-openssh-askpass` remains installed as a fallback but is unused.
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
