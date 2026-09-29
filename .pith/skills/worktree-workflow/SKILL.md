---
name: worktree-workflow
description: Use when repository instructions require a Git worktree, the user requests isolation, or parallel work needs a separate workspace. Select the recorded base and integration target, validate in isolation, then follow that repository's integration and approval rules.
invocation:
  model: true
  user: true
---

# Isolated Git Worktree Workflow

Use this workflow for Git worktrees. Repository instructions and any task's recorded workspace/integration target are authoritative; this skill does not impose a universal branch name, directory, PR policy, or validation command.

## Process

1. **Read the project rules.** Inspect applicable `AGENTS.md` files, contributor docs, the task or issue, Git status, remotes, branches, and existing worktrees. Determine whether a worktree is required or appropriate. If project rules say a change is exempt (for example, a docs-only change), follow that exception. Complete when the required workspace mode, base, integration target, validation, and handoff rules are known; ask only when a conflicting or missing choice blocks safe work.

2. **Protect existing work.** Inspect dirty files and existing worktrees before creating or switching workspaces. Preserve all uncommitted changes. If dirty files overlap the requested change, stop and ask how to proceed; if they are unrelated, continue without touching them. Reuse an existing worktree only when it is clearly the recorded workspace for this task and its state is understood. Complete when no unknown or overlapping state will be overwritten.

3. **Choose the base and location.** Use, in order: the task's recorded workspace; repository instructions; the repository's configured default branch. Determine a remote default branch from local remote metadata or the hosting service; never guess `main`, `master`, or another name. Use the recorded integration target for ticket lanes or multi-branch work; do not replace it with the default branch. Follow the repository's worktree directory convention; if none exists, use an ignored `.worktrees/<branch-slug>` path when available, otherwise choose a safe path and keep it out of tracked project files. Complete when branch, base, worktree path, and integration target are explicit and consistent.

4. **Create or verify the worktree.** Create a dedicated branch and worktree from the selected base, for example:

   ```bash
   git worktree add -b <branch> <worktree-path> <base-branch>
   ```

   If the branch or path already exists, inspect its owner, base, and cleanliness; do not silently reuse, reset, or remove it. Work from inside the selected worktree. Complete when the active directory and branch match the task's workspace record.

5. **Implement and validate.** Make the smallest correct change in the worktree. Run the checks required by that repository, plus any relevant focused tests. Keep commits, merges, pushes, and external issue updates within the repository's documented policy. Ask for explicit user approval before any such action not clearly requested. Complete when the agreed acceptance criteria are implemented, all applicable checks pass, and remaining failures or untestable criteria are reported.

6. **Integrate only to the recorded target.** Present the diff summary, commit state, validation evidence, and exact integration target. Do not create a PR, merge, rebase, cherry-pick, or push unless the repository workflow calls for it and the user has approved that specific action. Use the repository's documented integration method; never force-update shared history. After integration, run the required checks on the integrated target. Complete when the integration result and validation are verified, or the work is clearly handed off awaiting approval.

7. **Clean up safely.** Before removing a worktree or branch, verify that it belongs to this task and inspect its status. Preserve uncommitted work. Ask for explicit approval before deleting a worktree or branch unless the user explicitly requested that cleanup. Remove only resources created for this task, then verify the remaining worktree and branch state. Complete when cleanup is verified or the exact remaining workspace is reported for handoff.

## Stop conditions

Stop and report when the task's integration target conflicts with repository instructions, the intended base cannot be established, an existing workspace has unknown ownership or changes, or required validation fails. Preserve state rather than guessing, resetting, or forcing an integration.
