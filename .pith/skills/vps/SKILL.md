---
name: vps
description: Manage and connect to Daniel's personal VPS hosts (Hetzner servers accessed via SSH/Tailscale). Use whenever the user wants to connect to a VPS, check VPS status, copy files to/from a VPS, manage services running on a VPS (systemd, PM2, cron), tail remote logs, deploy code, or inspect what is running on a specific VPS host. Triggers on mentions of "VPS", "server", host aliases like "vps" or "danielmr-hel1", Hetzner servers in an operational (not infra-provisioning) context, remote services, remote logs, SSH into the box, SCP files, or asking "what is running on the VPS". Complementary to the `hcloud` skill — `hcloud` manages infrastructure (create/destroy servers, firewalls, DNS); this skill operates INSIDE an existing VPS.
---

# VPS

Operate Daniel's existing VPS hosts over SSH. Generic skill — one reference file per host in `hosts/`. For infrastructure changes (provisioning, firewalls, DNS), use the `hcloud` skill instead.

## Host selection

Skill handles one or more VPS hosts. Each host has a reference file at `hosts/<hostname>.md` with: SSH alias, IPs, user, what's running, repos, key paths. **Always read the relevant host file before operating** — paths and services differ per host.

Current hosts:
- `danielmr-hel1` → see `hosts/danielmr-hel1.md` (Hetzner Helsinki, Tailscale 100.89.11.76, SSH alias `vps`)

When the user says "the VPS" without specifying and only one host exists, assume that one. If multiple exist, ask.

## Connecting

SSH aliases live in `~/.ssh/config`. Never hardcode IPs in commands — use the alias so routing (Tailscale vs public) stays in one place.

```bash
ssh vps                  # interactive shell
ssh vps '<cmd>'          # one-shot
ssh vps -t '<cmd>'       # allocate TTY (for sudo prompts, tmux, etc.)
```

Prefer Tailscale IPs over public IPs when both exist — faster, no public-internet exposure, no firewall friction.

## Sudo

Sudo passwords live in macOS Keychain under service `vps-sudo-<hostname>`, account = SSH user. Retrieve via:

```bash
~/.claude/skills/vps/scripts/sudo-pass.sh <hostname>
```

Run sudo commands on the remote host by piping the password through stdin with `sudo -S`:

```bash
PASS=$(~/.claude/skills/vps/scripts/sudo-pass.sh danielmr-hel1)
ssh vps "echo '$PASS' | sudo -S systemctl restart caddy"
```

**Never** paste the password literal into commands, chat, scripts, or files. **Never** log or echo it. The keychain is the only source of truth.

If adding a new VPS, store its sudo password with:

```bash
security add-generic-password -a <user> -s vps-sudo-<hostname> -w -U
```

(Prompts interactively — don't pass `-w <value>` so the password doesn't end up in shell history.)

## Common operations

### Status snapshot

```bash
ssh vps 'uptime; df -h /; free -h; who'
```

For a full snapshot (disk, RAM, load, top processes, open ports), combine into one SSH call to save round trips.

### File transfer

```bash
scp ./local.txt vps:~/path/              # local → remote
scp vps:~/remote.txt ./                  # remote → local
scp -r ./dir vps:~/target/               # recursive
rsync -avz --progress ./dir/ vps:~/dir/  # prefer rsync for large / incremental
```

Use `rsync` over `scp` when syncing directories or when interruption is likely — it resumes and skips unchanged files.

### systemd services

```bash
ssh vps 'systemctl status caddy'                         # no sudo needed for status
ssh vps "echo '$PASS' | sudo -S systemctl restart caddy"
ssh vps 'journalctl -u caddy -n 100 --no-pager'          # logs
ssh vps 'journalctl -u caddy -f'                         # follow (ctrl-C to stop)
```

### PM2

PM2 runs as the SSH user, no sudo needed.

```bash
ssh vps 'pm2 list'
ssh vps 'pm2 logs <name> --lines 100 --nostream'
ssh vps 'pm2 restart <name>'
ssh vps 'pm2 save'       # persist process list across reboots
```

### Cron

```bash
ssh vps 'crontab -l'                # user crontab
ssh vps 'sudo -S crontab -l -u root' # with password for root crontab
ssh vps 'ls /etc/cron.d/'
```

### Tail logs

```bash
ssh vps 'tail -f /var/log/caddy/access.log'
ssh vps 'sudo -S tail -f /var/log/syslog' # with piped password
```

## Before doing anything destructive

Restarts, config edits, service stops, `rm`, and anything that touches other people's production (Pitchgale, client sites) warrant confirming with the user first, even if the user asked broadly. State what you're about to run and wait. See the global CLAUDE.md section on irreversible actions.

For edits to config files on the VPS, prefer editing locally (`scp` down → edit → `scp` up) over editing in-place with `nano`/`vim` over SSH — easier to review the diff, easier to roll back.

## Exploring what's on a host

If the user asks "what's running on the VPS" or similar discovery, read the host's reference file first — it has the curated answer. Only fall back to live inspection (`systemctl list-units`, `pm2 list`, `ls ~`) if the reference looks stale or the user asks for current state.

When you discover drift between `hosts/<hostname>.md` and reality (new service, removed repo, etc.), update the reference file so future sessions stay accurate.
