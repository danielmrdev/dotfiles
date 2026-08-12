# Daniel's Dotfiles — Omarchy/Arch

Personal dotfiles for the Omarchy (Arch + Hyprland) ThinkPad E15 Gen 4. Tracked files back live config through symlinks created by `restore.sh`. Scope: Omarchy config, zsh, terminals, and custom tooling — macOS-era and v3 leftovers were removed.

## Layout

| Path | What |
|---|---|
| `.config/hypr/*.lua` | Hyprland v4 Lua config (bindings, input, looknfeel, monitors, workspaces, autostart) |
| `.config/omarchy/` | `shell.json` (bar layout, idle), hooks (`.d` dirs), extensions, branding |
| `.config/omarchy/plugins/` | Customized clones: `daniel.weather` (temp in bar), `daniel.tray` (no drawer) |
| `install.sh` | Fresh-install entry point: restore + hooks + themes + plugins + gitleaks |
| `.config/alacritty/`, `.config/foot/`, `.config/ghostty/` | Terminals |
| `.config/btop/`, `.config/fastfetch/` | System info apps |
| `.config/systemd/user/` | User units: `espanso`, `teams-jiggler*`, `omarchy-recover-internal-monitor` |
| `.config/autostart/`, `.config/environment.d/` | Autostart desktop entries, env vars (`fcitx`, Wayland, `SUDO_ASKPASS`) |
| `.zshrc`, `.p10k.zsh`, `aliases.zsh`, `path.zsh` | zsh + powerlevel10k |
| `.local/bin/` | Custom scripts: `askpass`, `lid-is-open`, `teams-jiggler*`, `omniroute`, `neon-pilot-app`, `omarchy-webapp-patch`, `save-dotfiles`, `restore-dotfiles` |
| `.local/share/applications/` | Webapp desktop entries + icons (Teams, Outlook, WhatsApp, Hache, Tailscale) |
| `etc/pam.d/` | PAM policy (`sudo`, `polkit-1`) — root-owned copies, restore prints privileged commands |
| `.agents/skills/` | Agent skills (omarchy, dotfiles, etc.) |
| `.githooks/pre-commit` | Gitleaks secret scan (see below) |

## Restore (fresh or reset system)

```bash
bash restore.sh
```

Creates symlinks from `~/.dotfiles` to live config, reloads user systemd, prints the privileged commands needed for PAM/system files. Refuses non-empty destination directories. Inspect affected paths before running on an existing system.

## Install (fresh system)

On a fresh Omarchy install, run `install.sh` after cloning the repo — it drives everything: restore symlinks, enable the gitleaks hook, install Omarchy extras (Harbor theme, Omadoro plugin) and tooling (gitleaks):

```bash
git clone git@github.com:danielmrdev/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install.sh
```

Idempotent — safe to re-run.

## Omarchy plugins

| Kind | Install | Backup |
|---|---|---|
| Built-in (`omarchy.*`) | shipped with Omarchy | nothing — layout lives in `shell.json` |
| Cloned built-in (`omarchy plugin clone omarchy.X`) | `omarchy plugin clone <id>` | track `~/.config/omarchy/plugins/<user>.<id>/` in this repo |
| Third-party git (e.g. `b.omadoro`) | `omarchy plugin add <git-url> --enable` | not tracked (own git); re-install via `install.sh`, update with `omarchy plugin update <id>` |
| Hand-written | write under `~/.config/omarchy/plugins/<id>/` | track in this repo |

## Save

```bash
bash save.sh
```

Copies selected live configs into the repo, stages everything, creates a timestamped commit, and pushes when a remote exists. Run only with explicit approval. `save.sh` sets `core.hooksPath .githooks`.

## Secrets

Gitleaks runs as a pre-commit hook (`.githooks/pre-commit`) and blocks staged secrets. Verify history:

```bash
gitleaks git --redact --no-banner
```

Never print private keys, tokens, or passwords. `etc/pam.d/` and `.local/bin/lid-is-open` are security-sensitive; their root-owned copies are not symlinks.

## Omarchy v4 notes

- Hyprland config is Lua (`hl.*` API). User files load after Omarchy defaults: `monitors.lua`, `input.lua`, `bindings.lua`, `looknfeel.lua`, `autostart.lua`, `workspaces.lua`.
- Idle/lock/screensaver are handled by the Omarchy shell (`~/.config/omarchy/shell.json` → `idle`) and `omarchy-sleep-lock.service`; `hypridle`/`hyprlock` confs are obsolete.
- Validate changes: `hyprctl reload` + `hyprctl configerrors`.
- Never edit `/usr/share/omarchy/` (read-only package defaults); use `~/.config/` or this repo.

## License

MIT — see `license.txt`.
