---
name: vps
description: Manage Daniel's existing VPS hosts over SSH. Use when connecting to `vps-hel1` or `vps-mail`, checking status, transferring files, managing services, reading logs, or deploying. Host-specific infrastructure instructions live on each VPS.
---

# VPS

Operate Daniel's existing VPS hosts over SSH. This skill stores connection and safety rules only. Use each host's own `AGENTS.md` and infrastructure repository as source of truth for services, paths, deployments, runbooks, and recovery.

## Hosts and documentation

| Host | SSH alias | Remote documentation root |
|---|---|---|
| `vps-hel1` | `vps` | `/home/daniel/.ops/vps-hel1-infra` |
| `vps-mail` | `vps-mail` | `/home/daniel/.ops/vps-mail-infra` |

On `vps-hel1`, `/home/daniel/AGENTS.md` resolves into its documentation repository. On `vps-mail`, `/home/daniel/AGENTS.md` is separate from the repository. These paths are the current layout; verify remotely if a path is missing. Never assume one host's docs or procedures apply to the other.

If the user says only “the VPS,” ask which host.

## Before changing a VPS

Before any remote change—files, configuration, services, packages, deployments, users, or data—read that VPS's `/home/daniel/AGENTS.md` and the applicable service guide/runbook from its documentation root above. Read the remote file, not a local copy. Some host instructions may contain credentials: load the instructions through a redacted method, never dump credential values into tool output or chat. Follow any linked workflow/skill, verify live state, and stop if documentation conflicts with reality or leaves impact unclear. After validation, follow that host's documentation-update requirements.

If the remote instructions or applicable docs cannot be loaded safely, stop and ask the user before modifying that VPS.

## Connecting

SSH aliases live in `~/.ssh/config`. Use the host alias; never hardcode IPs. Prefer the configured Tailscale route for `vps-hel1` when available.

```bash
ssh vps                    # vps-hel1
ssh vps-mail               # vps-mail
ssh <alias> '<read-only command>'
```

## Sudo

For commands requiring root **on this machine**, follow `~/.agents/skills/sudo-askpass/SKILL.md` and use `sudo -A`.

That askpass helper elevates local commands only. For remote root commands, use an SSH TTY so the remote sudo prompt stays interactive:

```bash
ssh -t <alias> 'sudo <command>'
```

Never retrieve, store, interpolate, or pipe a VPS sudo password. If the execution environment cannot handle the remote prompt interactively, stop and ask the user to run the privileged command.

## Routine operations

Use the selected host's docs for service names, paths, deployment, and validation commands. These generic commands do not replace the host runbook:

```bash
ssh <alias> 'uptime; df -h /; free -h; who'                 # status
ssh <alias> 'systemctl status <unit>'                      # service status
ssh <alias> 'journalctl -u <unit> -n 100 --no-pager'       # recent logs
scp ./local-file <alias>:~/path/                           # copy to host
rsync -avz --progress ./dir/ <alias>:~/dir/                # sync directory
```

Never assume `git pull && restart` is a valid deployment procedure.

## Production and destructive actions

Before production restarts, service stops, remote config edits, deletions, or actions affecting client sites or mail, state the exact action and impact, then wait for explicit confirmation. For remote config edits, prefer copying the file locally, reviewing the diff, then transferring it back; keep a rollback copy when practical.
