# Vendored engineering skills

These skills are the Pith-owned global snapshot of the Matt Pocock engineering skills installed in `~/.agents/skills/`.

## Policy

- The vendored copies are the runtime source for this user environment and must not be replaced by syncing `~/.agents/skills/`.
- Upstream updates are reviewed and imported deliberately; preserve Pith adaptations when doing so.
- Pith skills are invoked through the `skill` tool using their name (for example, `skill:to-spec`), not Claude Code slash-command syntax.
- Interactive choices use the `ask_user_question` tool. Browser work uses Pith browser tools; parallel independent work uses `subagent`.
- Repository code changes still follow each project repository workflow; global skill changes are process-document changes.

## Snapshot

- **Upstream root:** `~/.agents/skills/` (resolved from `/home/daniel/.dotfiles/.agents/skills` on this machine)
- **Upstream snapshot:** dotfiles commit `6836cb5` (`dotfiles: save 2026-09-07_1039`)
- **Pith adaptation baseline:** dotfiles commit `fa34aeb` (`skills: add spec workspace and ticket map workflow`)
- **Vendored skills:** 25 engineering skills listed below

## Skills

`ask-matt`, `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-me`, `grill-with-docs`, `grilling`, `handoff`, `implement`, `improve-codebase-architecture`, `prototype`, `research`, `resolving-merge-conflicts`, `setup-matt-pocock-skills`, `tdd`, `teach`, `to-questionnaire`, `to-spec`, `to-tickets`, `triage`, `wait-what`, `wayfinder`, `wizard`, `writing-for-agents`.

The `agents/openai.yaml` files from the global source were intentionally not copied: they are metadata for another host, not part of a Pith skill.
