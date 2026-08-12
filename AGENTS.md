# Dotfiles Context

Personal configuration for Daniel's Omarchy/Arch laptop. Repository lives at `~/.dotfiles`; tracked files are intended to back live config through symlinks created by `restore.sh`.

## Workflow

- Inspect `git status` before editing. Preserve unrelated work.
- Prefer editing tracked files in this repository. Do not assume a live config is still symlinked after an Omarchy reset; check with `readlink` when relevant.
- Keep changes minimal. When tracking a new config or script, update both `save.sh` and `restore.sh` so save/restore remain symmetric.
- The repo is scoped to Omarchy plus personal laptop config (zsh, terminals, custom scripts); macOS and v3-era leftovers were removed.
- For desktop, Hyprland, terminal, theme, hook, or other Omarchy changes, follow [Omarchy guidance](.agents/skills/omarchy/SKILL.md).
- For repository save/restore operations, follow [dotfiles guidance](.agents/skills/dotfiles/SKILL.md).

## Commands

- Validate scripts: `bash -n save.sh restore.sh install.sh`
- Post-clean-install extras (themes, plugins, gitleaks): `bash install.sh`
- Inspect changes: `git status --short && git diff`
- Restore symlinks on a fresh or reset system: `bash restore.sh`
- Save selected live configs: `bash save.sh`

`save.sh` stages every repository change, creates a timestamped commit, and pushes when a remote exists. Run it only with explicit user approval. It does not accept a custom commit message.

`restore.sh` replaces existing files/symlinks, refuses non-empty destination directories, reloads user systemd, and only prints the privileged commands needed for PAM/system files. Inspect affected paths before running it on an existing system.

## Safety and verification

- Never commit, push, reset, delete tracked config, run privileged commands, or restart production/server services without explicit approval.
- Never edit `/usr/share/omarchy/`; use user config under `~/.config/` or this repository.
- Treat `etc/pam.d/` and `.local/bin/lid-is-open` as security-sensitive. Root-owned copies are not symlinks.
- Omarchy refresh commands can overwrite symlink targets inside this repository. Confirm first and inspect the resulting diff.
- Do not track Omarchy-managed themes, wallpapers, backup artifacts, or generated systemd `*.target.wants` links.
- After Hyprland changes, run `hyprctl reload` and `hyprctl configerrors`.
- After user unit changes, run `systemctl --user daemon-reload` and a targeted unit check.
- Gitleaks runs as a pre-commit hook (`.githooks/pre-commit`); never bypass it.
