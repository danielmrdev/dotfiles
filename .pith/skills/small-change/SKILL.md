---
name: small-change
description: Small-change workflow for a clear bug fix or brief implementation that fits one focused session. Use when scope and acceptance criteria are settled.
invocation:
  model: true
  user: true
---

# Small Changes

A small change is one independently verifiable outcome with no open product decisions. Judge by scope and uncertainty, not line count.

## Process

1. **Bound the task.** Inspect current behaviour and enough of the project to identify the owning area, contracts, acceptance criteria, and verification. If product decisions remain open, use `grill-with-docs`. If the bug is hard, intermittent, or unexplained, use `diagnosing-bugs`. If this is an untriaged external request, use `triage`. If it needs multiple sessions or independent tickets, use `grill-with-docs` → `to-spec` → `to-tickets`. For a dependency or SDK update, follow the project's update workflow. Complete when one focused session can deliver and verify one outcome, or the task has been routed to the right flow.

2. **Anchor the work.** Inspect the project's instructions to find its issue tracker and workflow. Read any supplied ticket; search for duplicates when the tracker supports it. Use `gh-issue` for GitHub Issues, otherwise use the configured tracker. Create a ticket only when the user requests it or the project workflow requires one. Get explicit approval before an unrequested external write; perform a clearly requested write only within its stated scope. Complete when scope and acceptance criteria are recorded in the task or ticket, or the project does not use a tracker.

3. **Prepare the workspace.** Follow the repository's branch and worktree rules. Use `worktree-workflow` when an isolated Git worktree is required by project instructions or is the chosen safe workspace. Follow any recorded integration target; never assume a default branch or a GitHub `Workspace` convention. Complete when the working branch/worktree and integration target match project policy, or the documented exception applies.

4. **Implement.** Make the smallest correct change in the selected workspace. For behaviour changes with a useful test seam, use `tdd` one red-green slice at a time and follow its seam-agreement rules. Reassess scope if implementation reveals new decisions, independent outcomes, or work beyond one session. Complete when every acceptance criterion is implemented and verified at an appropriate seam; record why if a criterion has no useful automated test.

5. **Verify and review.** Run the checks required by the repository and use `code-review` when available, against the task and intended integration target. For documentation-only changes, follow the repository's documented exception and review the diff. Resolve findings or report any that remain. Complete when all applicable checks are green, review findings are resolved or explicitly reported, and the diff matches the agreed scope.

6. **Complete the work.** Follow repository policy and explicit user approvals for commits, merges, pushes, ticket updates, and cleanup. Close a ticket only when the user requests it or the project workflow authorizes closure after verified completion; verify the resulting state. Report the task or ticket, changed paths, verification results, integration state, and any remaining approval or handoff. Complete when the final state is verified and any active workspace is cleaned up or clearly handed off.

## Escalation

This flow is for one outcome in one focused session. New decisions, multiple deliverables, or work beyond one session return to `grill-with-docs` → `to-spec` → `to-tickets` before more implementation work.
