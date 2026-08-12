---
name: dotfiles
description: Manage Daniel's symlink-based dotfiles repository at ~/.dotfiles, including save/restore, tracking new configs, checking changes, and repairing symlinks.
---

# Dotfiles Workflow

Use this skill for repository lifecycle work: save, restore, add tracked config, inspect changes, or repair symlinks. For config content under Omarchy, Hyprland, Waybar, or terminals, also use the Omarchy skill.

## Architecture

`~/.dotfiles` stores tracked config. `restore.sh` creates symlinks from normal locations into this repository; `.zshrc` sources `aliases.zsh` and `path.zsh` directly instead of symlinking them.

Omarchy resets can replace live symlinks with regular files. Check relevant paths with `readlink` or `test -ef` instead of assuming current state.

## Before changing anything

1. Run `git status --short` and preserve unrelated work.
2. Read the relevant sections of `save.sh` and `restore.sh`; these scripts are the current tracking inventory.
3. Confirm before any commit, push, reset, destructive restore, privileged copy, or Omarchy refresh.

## Normal edits

Prefer editing tracked repository files. If editing a live path, verify it resolves to the intended repository file.

For a new config or script:

1. Add its tracked copy under the matching repository-relative path.
2. Add save logic to `save.sh`.
3. Add matching link logic to `restore.sh`.
4. Preserve executable mode for scripts.
5. Validate both scripts with `bash -n save.sh restore.sh`.
6. Inspect the focused diff. Do not commit or push without explicit approval.

Do not track backup artifacts, Omarchy-managed themes/wallpapers, dynamic current-theme links, or generated systemd `*.target.wants` links.

## Save

`bash save.sh`:

- Copies selected live files when they are not already the same file as the repository target.
- Rewrites `.gitignore` to its built-in list.
- Runs `git add -A`, commits all staged repository changes with a timestamp, then pushes if `origin` exists.
- Stops on copy or Git errors because it uses `set -e`.
- Does not accept a custom commit message.

This operation can include unrelated changes. Show status/diff and obtain explicit approval before running it.

## Restore

`bash restore.sh`:

- Replaces destination files and symlinks with links into this repository.
- Refuses to replace non-empty destination directories.
- Links user config, scripts, skills, services, and web-app assets covered by the script.
- Reloads user systemd.
- Prints, but does not execute, privileged deployment commands for PAM and `lid-is-open`.

On an existing system, inspect destinations and back up untracked live config before approval. On a fresh clone, run from `~/.dotfiles`.

## Verification

- Shell syntax: `bash -n save.sh restore.sh`
- Repository state: `git status --short && git diff`
- Symlink: `readlink <live-path>` or `test <live-path> -ef <repo-path>`
- Hyprland: `hyprctl reload && hyprctl configerrors`
- Waybar: `omarchy restart waybar`
- User units: `systemctl --user daemon-reload`, then check only affected units
