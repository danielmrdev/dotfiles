---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Before changing code, read the ticket's complete `Workspace` section and resolve its execution mode, current branch, worktree, and `Integrates into` branch. Treat those values as the source of truth. If the ticket is a parallel lane, its completion target is the recorded integration branch, not the repository default branch.

Use `skill:tdd` where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use `skill:code-review` to review the work.

Commit your work to the current branch. At completion, report the validation results and the recorded merge target. A lane completion may propose only local integration into that target; it must not propose integration into `main` (or another default branch). Proposing the default-branch merge is reserved for the spec integration owner after every ticket has landed and full integrated validation is green.
