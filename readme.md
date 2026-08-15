# Daniel's Dotfiles — Omarchy/Arch

Personal dotfiles for the Omarchy (Arch + Hyprland) ThinkPad E15 Gen 4. Tracked files back live config through symlinks created by `restore.sh`. Scope: Omarchy config, zsh, terminals, and custom tooling — macOS-era and v3 leftovers were removed.

## Layout

| Path | What |
|---|---|
| `.config/hypr/*.lua` | Hyprland v4 Lua config (bindings, input, looknfeel, monitors, workspaces, autostart) |
| `.config/omarchy/` | `shell.json` (bar layout, idle), hooks (`.d` dirs), extensions, branding |
| `.config/omarchy/plugins/` | Customized clones: `daniel.weather` (temp in bar), `daniel.tray` (no drawer) |
| `install.sh` | Fresh-install entry point: restore + hooks + themes + plugins + gitleaks |
| `.config/alacritty/` | Terminal config |
| `.config/btop/`, `.config/fastfetch/` | System info apps |
| `.config/systemd/user/` | User units: `espanso`, `teams-jiggler*`, `omarchy-recover-internal-monitor`, CalDAV calendar sync |
| `.config/hyprshell/` | Window switcher (SUPER+TAB) config + theme — hyprshell is the v4 switcher, keep service enabled |
| `.config/autostart/`, `.config/environment.d/` | Autostart desktop entries, env vars (`fcitx`, Wayland, `SUDO_ASKPASS`) |
| `.zshrc`, `.p10k.zsh`, `aliases.zsh`, `path.zsh` | zsh + powerlevel10k |
| `.local/bin/` | Custom scripts: `askpass`, `lid-is-open`, `teams-jiggler*`, `omniroute`, `neon-pilot-app`, `omarchy-webapp-patch`, `omarchy-calendar-sync-caldav`, `update-fingerprint-libs`, `save-dotfiles`, `restore-dotfiles` |
| `packages/aur-fingerprint.txt` | AUR package manifest for ThinkPad Goodix fingerprint support |
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

On a fresh Omarchy install, run `install.sh` after cloning the repo — it drives everything: restore symlinks, enable the gitleaks hook, install Omarchy extras (Harbor theme, Omadoro and Calendar plugins), CalDAV widget dependencies, and tooling (gitleaks):

```bash
git clone git@github.com:danielmrdev/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install.sh
```

Idempotent — safe to re-run. It also installs or updates the AUR packages listed in `packages/aur-fingerprint.txt`.

## ThinkPad fingerprint reader

This ThinkPad (`21E6004WSP`) has a Goodix USB reader with ID `27c6:550a`.
The official Arch package `libfprint` does not include support for this device.
Fingerprint support therefore uses two locally built AUR packages:

- `libfprint-tod` — libfprint with the TOD API needed by external drivers.
- `libfprint-2-tod1-goodix` — Lenovo's proprietary Goodix driver for `27c6:550a`.

Do not replace them with the official `libfprint` package: it conflicts with
`libfprint-tod` and leaves `fprintd` without a driver for this reader.

Package lifecycle:

- `install.sh` reads the manifest and runs `yay -S --needed`, installing or updating both packages.
- `omarchy update` also runs Omarchy's AUR update step (`yay -Sua`).
- The AUR Goodix entry currently advertises `0.0.9-1`, while the installed
  `0.0.9.r3.g5f05f60-1` is newer. Its AUR `Out-of-date` flag is metadata noise,
  not an available downgrade.
- After `restore.sh`, update manually with:

  ```bash
  update-fingerprint-libs
  ```

- Inspect installed/AUR versions without changing anything:

  ```bash
  update-fingerprint-libs --check
  ```

- Rebuild locally when the AUR source changes without a version bump:

  ```bash
  update-fingerprint-libs --rebuild
  ```

`save.sh` preserves the updater script; `restore.sh` restores it with the other
custom scripts. The package manifest is versioned in this repository, not
symlinked into a live config path.

## Omarchy plugins

| Kind | Install | Backup |
|---|---|---|
| Built-in (`omarchy.*`) | shipped with Omarchy | nothing — layout lives in `shell.json` |
| Cloned built-in (`omarchy plugin clone omarchy.X`) | `omarchy plugin clone <id>` | track `~/.config/omarchy/plugins/<user>.<id>/` in this repo |
| Third-party git (e.g. `b.omadoro`) | `omarchy plugin add <git-url> --enable` | not tracked (own git); re-install via `install.sh`, update with `omarchy plugin update <id>` |
| Hand-written | write under `~/.config/omarchy/plugins/<id>/` | track in this repo |

## Barra de Omarchy

Orden actual en `~/.config/omarchy/shell.json`. `CUSTOM` = plugin externo o widget propio; los `omarchy.*` son widgets first-party de Omarchy.

| Sección | Orden | Widget | Origen |
|---|---:|---|---|
| Centro | 1 | `omarchy.indicators` | Omarchy |
| Centro | 2 | `tmn73.calendar` | **CUSTOM** — plugin externo |
| Centro | 3 | `omarchy.keyboard-layout` | Omarchy |
| Centro | 4 | `daniel.weather` | **CUSTOM** — widget propio |
| Centro | 5 | `omarchy.system-update` | Omarchy |
| Izquierda | 1 | `omarchy.menu` | Omarchy |
| Izquierda | 2 | `daniel.workspaces` | **CUSTOM** — widget propio |
| Derecha | 1 | `daniel.tray` | **CUSTOM** — widget propio |
| Derecha | 2 | `codefriendly.nightman` | **CUSTOM** — plugin externo |
| Derecha | 3 | `b.omadoro` | **CUSTOM** — plugin externo |
| Derecha | 4 | `omarchy.tailscale` | Omarchy |
| Derecha | 5 | `omarchy.agents` | Omarchy |
| Derecha | 6 | `omarchy.bluetooth` | Omarchy |
| Derecha | 7 | `omarchy.network` | Omarchy |
| Derecha | 8 | `omarchy.audio` | Omarchy |
| Derecha | 9 | `daniel.sysinfo` | **CUSTOM** — widget propio |
| Derecha | 10 | `omarchy.monitor` | Omarchy |
| Derecha | 11 | `omarchy.power` | Omarchy |

### Calendario

`tmn73.calendar` reemplaza al reloj integrado. Eventos vienen de CalDAV/Stalwart mediante `.local/bin/omarchy-calendar-sync-caldav`.

- Dependencias: `python-icalendar`, `python-dateutil` (las instala `install.sh`).
- Timer: `omarchy-calendar-sync-caldav.timer`, cada 5 minutos.
- Credencial local: `~/.config/omarchy/calendar-caldav.password` (`chmod 600`, no se versiona).
- Fuente: `https://jmap.danielmr.dev/dav/cal`.
- Widget consume: `~/.local/state/omarchy/calendar-events.json`.
- Colores: usa `calendar-color` nativo de CalDAV; cada evento lleva color en JSON.

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
