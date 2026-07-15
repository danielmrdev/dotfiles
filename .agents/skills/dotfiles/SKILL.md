---
name: dotfiles
description: Manage Daniel's dotfiles repo at ~/.dotfiles/ — symlink-based saving/restoring of omarchy desktop config, systemd services, scripts, and shell setup. Use when asked to save current config, restore after upgrade, add new configs to tracking, commit changes, or push to GitHub. Covers the workflow between ~/.dotfiles/ (git repo), save.sh, restore.sh, and the symlink architecture.
---

# Dotfiles Skill

System for tracking Daniel's desktop config with a git repo + symlinks approach.

**Repo**: `~/.dotfiles/` → `git@github.com:danielmrdev/dotfiles.git` (branch `main`)

**Architecture**: Configs live at their standard locations (`~/.config/hypr/bindings.conf`,
`~/.config/waybar/config.jsonc`, etc.) but are **symlinked** from `~/.dotfiles/`.
Editing a config automatically edits the file inside the repo — changes are
always versioned.

## When This Skill MUST Be Used

**ALWAYS invoke this skill when the user asks ANY of these:**

- Save current configs / backup dotfiles
- Commit and push config changes to GitHub
- Restore configs after omarchy update or `omarchy reinstall configs`
- Add a new config file or script to the dotfiles repo
- Check what configs are tracked / what changed
- Migrate or set up dotfiles on a new machine
- Fix broken symlinks
- Any operation involving `~/.dotfiles/save.sh` or `~/.dotfiles/restore.sh`
- "I changed something, commit it" — run save.sh

**Do NOT use this skill for** modifying the content of config files themselves
(use the omarchy skill for hypr/waybar/walker/terminal configs).

## Repo Location

```
~/.dotfiles/
├── .zshrc              # Symlinked to ~/.zshrc
├── .p10k.zsh           # Symlinked to ~/.p10k.zsh
├── aliases.zsh         # NOT symlinked — sourced by .zshrc from here
├── path.zsh            # NOT symlinked — sourced by .zshrc from here
├── save.sh             # Save script
├── restore.sh          # Restore script
├── AGENTS.md           # Full documentation (read for detailed reference)
├── .gitignore
├── .config/
│   ├── hypr/           # Hyprland: bindings, monitors, workspaces, idle, lock, envs, autostart
│   ├── waybar/         # config.jsonc, style.css
│   ├── walker/         # config.toml
│   ├── swayosd/        # config.toml, style.css
│   ├── btop/           # btop.conf
│   ├── fastfetch/      # config.jsonc
│   ├── alacritty/      # alacritty.toml
│   ├── ghostty/        # config
│   ├── foot/           # foot.ini
│   ├── systemd/user/   # *.service, *.timer, *.service.d overrides
│   ├── autostart/      # *.desktop files
│   ├── environment.d/  # fcitx.conf, omarchy-firefox-wayland.conf
│   ├── chromium-flags.conf
│   └── omarchy/        # hooks, themes/harbor (custom theme), extensions, branding
└── .local/bin/         # teams-jiggler*, nextcloud-external-guard, neon-pilot-app, omniroute
```

Total: ~90 tracked files.

## Key Scripts

### `save.sh` — Backup current configs + commit + push

```bash
~/.dotfiles/save.sh                    # auto commit with timestamp
~/.dotfiles/save.sh "pre-update backup"  # custom message
```

**How it works**:
1. Iterates over each tracked area (hypr, waybar, systemd, etc.)
2. For each file, checks if source is already symlinked into the repo (`test -ef` same inode check)
3. If yes → skips (changes already tracked via symlink)
4. If no (regular file, e.g. after `omarchy refresh`) → copies into repo
5. Only copies regular files, skips directories and `.bak.*` files
6. `git add -A`, commits, pushes

**Idempotent**: running twice with no changes shows "Nothing changed — skipping commit."

### `restore.sh` — Recreate symlinks

```bash
~/.dotfiles/restore.sh
```

**When to use**:
- On a brand new OS install after cloning the repo
- After `omarchy reinstall configs` resets everything
- After `omarchy refresh` overwrites files

**What it does**:
1. Creates all necessary parent directories
2. Creates symlinks from `~/.dotfiles/` → original locations
3. Skips `.bak.*` files
4. Runs `systemctl --user daemon-reload`

**Important**: `aliases.zsh` and `path.zsh` are NOT symlinked. They are sourced
directly by `.zshrc` from `~/.dotfiles/`. Do NOT create symlinks for them.

## Symlink Architecture

Every tracked file lives at its standard location AND is symlinked into the repo:

```
~/.config/hypr/bindings.conf  →  ~/.dotfiles/.config/hypr/bindings.conf
~/.zshrc                      →  ~/.dotfiles/.zshrc
~/.local/bin/teams-jiggler    →  ~/.dotfiles/.local/bin/teams-jiggler
```

**Consequences**:
- Editing the original edits the repo file — no manual copy needed
- `git status` shows real changes automatically
- `git checkout` on a file in `~/.dotfiles/` restores the original too (via symlink)
- `omarchy refresh` follows symlinks and overwrites the file in `~/.dotfiles/`
  → after refresh, `git diff` shows what changed, `git checkout` reverts it

## Common Operations

### Quick save (one-liner)
```bash
cd ~/.dotfiles && git add -A && git commit -m "dotfiles: update hypr keybinds" && git push
```

### See what changed
```bash
cd ~/.dotfiles && git diff --stat
cd ~/.dotfiles && git diff .config/hypr/bindings.conf
```

### Revert a single file to saved version
```bash
cd ~/.dotfiles && git checkout -- .config/hypr/bindings.conf
# Symlink means this restores ~/.config/hypr/bindings.conf too
```

### Add a new config file to the system
1. Create file at standard location (e.g. `~/.config/newapp/config.toml`)
2. Copy into repo: `cp ~/.config/newapp/config.toml ~/.dotfiles/.config/newapp/`
3. Replace with symlink: `ln -sf ~/.dotfiles/.config/newapp/config.toml ~/.config/newapp/config.toml`
4. Add path to `save.sh` in the appropriate section
5. `cd ~/.dotfiles && git add -A && git commit -m "dotfiles: add newapp config" && git push`

### Add a new custom script
Same pattern: place in `~/.local/bin/`, copy to `~/.dotfiles/.local/bin/`,
symlink back, add to save.sh's script section, commit.

### What NOT to track
- `.bak.*` files — ignored via `.gitignore`
- `default.target.wants/`, `graphical-session*.target.wants/`, `timers.target.wants/`
  inside systemd/user — regenerated by `systemctl enable`
- `~/.config/mako/config` — managed by omarchy theme system
- `~/.config/omarchy/current/` — dynamic, managed by omarchy

## Omarchy Integration

| Action | Effect on dotfiles |
|--------|-------------------|
| `omarchy refresh hyprland` | Overwrites symlink target in `~/.dotfiles/`. `git diff` to see changes, `git checkout` to revert. |
| `omarchy refresh waybar` | Same — overwrites via symlink. Re-run `restore.sh` to restore symlink if broken. |
| `omarchy reinstall configs` | Resets ALL configs to defaults — files become regular (not symlinks). Run `restore.sh` after. |
| `omarchy theme set` | Changes mako config symlink (not tracked). Safe. |
| `omarchy update` | System update — safe. Run `save.sh` before. |

### Recommended upgrade workflow
```bash
~/.dotfiles/save.sh                    # backup to GitHub
omarchy snapshot create                # optional btrfs snapshot
# then: omarchy update
# if something is overwritten:
~/.dotfiles/restore.sh                 # restore symlinks
```

## Safety Rules

1. **Never delete** original symlink targets inside `~/.dotfiles/` — it breaks live config.
2. **restore.sh** removes whatever is at the destination (file or symlink) before
   recreating the symlink. It won't remove non-empty directories.
3. **save.sh** with `set -e` — if any cp fails, the script stops. The `safe_cp`
   function handles the symlink-same-file case gracefully.
4. **aliases.zsh and path.zsh** are NOT symlinks. They are regular files inside
   `~/.dotfiles/` sourced by `.zshrc`. Do NOT create symlinks for them.
5. **After any Hyprland config change**: validate with `hyprctl reload` and
   `hyprctl configerrors`.
6. **After any Waybar config change**: `omarchy restart waybar`.
7. **Always run** `hyprctl configerrors` after hyprland changes.
