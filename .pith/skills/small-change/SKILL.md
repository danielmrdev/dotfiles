---
name: small-change
description: Use for one focused bug fix or implementation with clear scope; create or reuse and self-assign a labeled issue, then implement through verified integration, cleanup, and closure under repo policy.
invocation:
  model: true
  user: true
---

# Small Changes

A small change is one independently verifiable outcome with no open product decisions. Judge by scope and uncertainty, not line count.

## Process

1. **Understand and bound.** Inspect current behaviour and enough of the project to identify the owner, contracts, scope, acceptance criteria, and verification. Settle the change before opening an issue. If product decisions remain open, use `grill-with-docs`; if a bug is hard, intermittent, or unexplained, use `diagnosing-bugs`; if this is an untriaged external request, use `triage`; if it needs multiple sessions or tickets, use `grill-with-docs` → `to-spec` → `to-tickets`. Follow the project's update workflow for dependency or SDK work. **Done when** one focused session can deliver one outcome, or the task has been routed.

2. **Create and own the issue.** Resolve the tracker from project instructions. For GitHub, use `gh-issue` to inspect templates and label mappings and search for duplicates. Read and reuse a supplied or exact open issue; ask before adopting one assigned to someone else or reopening a closed duplicate. Otherwise, once scope is settled and before implementation, create one issue with the goal, scope, acceptance criteria, and verification. Apply the existing category and agent-ready state labels specified by the repository's label map, plus relevant existing component labels where used. Never invent labels; if the mapping is missing or unclear, stop and ask. Self-assign to the authenticated account (`@me` on GitHub). If a required label or assignment cannot be applied, stop before implementation. If no tracker is configured, ask whether to continue without one. **Done when** the issue URL, body, labels, and self-assignment are verified and its number is recorded.

3. **Prepare the workspace.** Follow the repository's branch, worktree, and integration rules; use `worktree-workflow` when applicable. Base branch and integration target come from repository policy or the issue's workspace record, not assumption. Use the issue number in branch/commit names when required. If the repository requires a `Workspace` section, add it to the issue once the branch and worktree names are chosen and before creating the worktree. **Done when** the selected workspace and target match project policy and the issue records them when required.

4. **Implement.** Make the smallest correct change in the selected workspace. For behaviour changes with a useful test seam, use `tdd` one red-green slice at a time and follow its seam-agreement rules. Reassess scope if implementation reveals new decisions, independent outcomes, or work beyond one session; update the issue only within the agreed scope. **Done when** every acceptance criterion is implemented and verified at an appropriate seam, or the reason it has no useful automated test is recorded.

5. **Verify and prepare integration.** Run the checks required by the repository and use `code-review` when available, against the issue and intended integration target. For documentation-only changes, follow the repository's exception and review the diff. Resolve findings or report any that remain. Commit and link the issue according to repository policy; obtain any required approval before committing. **Done when** applicable checks are green, findings are resolved or reported, and the diff matches the issue.

6. **Integrate, clean up, and close.** Present the diff, commit, and checks; obtain and wait for any explicit merge approval required by repository policy. Follow the recorded integration method; never force. After merging, run required checks on the integration target. Only if they pass, remove the task-owned worktree and branch and verify both are gone. Then close the issue with a concise completion reason and verify its state; if it was auto-closed, verify that instead. Do not push without separate explicit approval. If merge, validation, cleanup, or closure fails, preserve remaining state, leave the issue open when possible, and report the exact handoff. **Done when** integration and target checks are verified, task resources are cleaned up, and the issue is confirmed closed.

## Escalation

This flow is for one outcome in one focused session. New decisions, multiple deliverables, or work beyond one session return to `grill-with-docs` → `to-spec` → `to-tickets` before more implementation work.
