# danielmr-hel1

Daniel's main personal VPS. Hetzner Cloud, Helsinki (hel1), Cx33. Hosts every public and private site Daniel runs.

## Access

| Field | Value |
|---|---|
| SSH alias | `vps` (see `~/.ssh/config`) |
| Tailscale IP | `100.89.11.76` |
| Public IPv4 | `157.180.120.160` |
| Public IPv6 | `2a01:4f9:c013:8d67::/64` |
| SSH user | `daniel` |
| SSH key | `~/.ssh/id_rsa` (default) |
| OS | Ubuntu 24.04.4 LTS |
| Hetzner server ID | `114793240` |

Prefer the Tailscale IP / `vps` alias over the public IP. The public IP is only for sites served by Caddy.

## Sudo

Password stored in macOS Keychain. Retrieve with:

```bash
~/.claude/skills/vps/scripts/sudo-pass.sh danielmr-hel1
```

## What's running

### Caddy (systemd: `caddy.service`)

Reverse proxy + static server for every site on the box. Config:

- `/etc/caddy/Caddyfile` — root config
- `/etc/caddy/sites/*.caddy` and `*.conf` — one file per site

Sites configured (as of 2026-04-23):

**Public:**
- `danielmr.dev` — personal site
- `tsa.monster` — dummy site for Amazon Associates verification
- `pitchgale.com`, `app.pitchgale.com`, `pre.pitchgale.com`, `app-pre.pitchgale.com`, `t.pitchgale.com` — Pitchgale (SaaS)
- `mailydone.com` — Mailydone pSEO site
- `equipamientobaristapro.com`, `cookcleanly.com` — BuilderMonster-generated affiliate sites

**Private (Tailscale-only):**
- `hcm.danielmr.dev` — better-copilot panel
- `hermes.danielmr.dev` — Hermes agent dashboard
- `stats.danielmr.dev` — Plausible analytics

Reload Caddy after config edits:

```bash
ssh vps "echo '$PASS' | sudo -S systemctl reload caddy"
```

### PM2

Node process manager for long-running apps and workers. Currently empty list — migrate here when adding persistent JS workers (Hermes agents, Pitchgale workers, etc.).

```bash
ssh vps 'pm2 list'
ssh vps 'pm2 logs <name> --lines 100 --nostream'
```

### Other systemd services (under `~/services/`)

- `~/services/caddy/` — supplementary Caddy config/scripts
- `~/services/plausible/` — self-hosted Plausible analytics
- `~/services/curl-proxy/` — lightweight HTTP proxy
- `~/services/syncthing/` — Syncthing config (the binary runs as a systemd user service)

### Agents / bots

- **Hermes** (Nous Research agents) — lives under `~/nous` and/or `~/hache`. Exposes Telegram channel. Dashboard at `hermes.danielmr.dev`.
- **better-copilot** (`~/better-copilot`) — private Better Consultants tooling. Panel at `hcm.danielmr.dev`.
- **nanoclaw-private** (`~/nanoclaw-private`) — Daniel's personal assistant system.

### Syncthing

Central hub node for Daniel's Syncthing mesh (Mac, VPS, iOS).

- `~/obsidian-vault` — shared Obsidian vault (the Nova `docs/` symlink on the Mac points here via Syncthing)
- `~/mac-vps-sync` — fast Mac↔VPS file drop (mounted in macOS Finder for drag-and-drop). Use it for quick transfers when `scp` is overkill.

### Claude Code

`claude` CLI is installed on the VPS. Can be invoked over SSH for remote agent runs (`ssh vps 'claude -p "..."'`).

## Project repos

| Repo | Path |
|---|---|
| Pitchgale | `~/pitchgale` |
| Mailydone | `~/mailydone` |
| BuilderMonster | `~/monster` |
| danielmr.dev | `~/danielmr.dev` |
| Hermes / Nous | `~/nous`, `~/hache` |
| better-copilot | `~/better-copilot` |
| nanoclaw-private | `~/nanoclaw-private` |

Deploys for these are project-specific — don't assume `git pull && restart`. Check the repo's own docs/scripts first.

## Known issues / cautions

- **Disk**: root filesystem was at 92% (66G / 75G) as of 2026-04-23. Watch out before pulling large artifacts, and flag to Daniel if it creeps higher.
- **Don't auto-deploy Pitchgale `main`** — manual review gate until M5 of Nova's roadmap ships.
- **`obsidian-vault` is a live Syncthing node** — don't `rm -rf` or bulk-rename files on the VPS side without pausing Syncthing first, or the Mac and iOS nodes will mirror the destruction.
