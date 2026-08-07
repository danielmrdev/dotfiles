---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker — edges as text in one file per ticket locally, or native blocking links on a real tracker.
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it. A run is complete only when the tickets and a visual dependency map contain their real tracker IDs, execution frontiers, and local workspace instructions.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments. Complete when the source, decisions, constraints, and existing tracker state are accounted for.

### 2. Verify the spec workspace

Read the spec's **Implementation Workspace** section and verify its local integration branch/worktree. The **primary checkout** is the original repository checkout that owns `.worktrees/`, not any linked worktree. The branch must be local-only, the worktree must live under the primary checkout's `.worktrees/`, and both must agree with the spec. If an existing source has no workspace, run `/to-spec` against that same reference so it updates the source in place; never create a duplicate spec. Complete when the integration worktree is clean and the recorded branch/path are real.

### 3. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change." Complete when ticket boundaries reflect the current architecture, glossary, relevant ADRs, and any necessary enabling prefactor.

### 4. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

Identify every execution **frontier**: tickets whose blockers can be satisfied at the same time and which do not depend on each other. Mark which frontier tickets can run concurrently in isolated lanes and which must remain sequential in the integration worktree. Complete when every ticket has blockers, an execution mode, and a demoable outcome.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

### 5. Build the visual ticket map

Create `<primary-checkout>/.scratch/<feature-slug>/ticket-map.html` before asking for approval. Keep the map in the primary checkout rather than the temporary integration worktree so workspace cleanup does not remove it; do not commit it unless repo policy explicitly requires that. Make it responsive, readable in light/dark mode, and open it in the in-app browser. It must show:

- Temporary ticket ordinals, titles, and blocking arrows.
- Topological frontier layers (`F0`, `F1`, …): `F0` has no open blockers; each later layer becomes available only after every blocker in earlier layers completes.
- The spec integration branch/worktree.
- Every parallel lane branching from and merging back into the integration branch.
- Validation and cleanup points for lane merges and the final default-branch merge.
- A clear local-only marker: no integration or lane branch is pushed.

Complete when the graph and numbered breakdown express the same dependencies and workspace plan.

### 6. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

Iterate on both the list and visual map until the user approves the granularity, blocking edges, frontiers, and workspace plan. Complete when the user explicitly approves all four.

### 7. Publish the tickets to the configured tracker

Publish the approved tickets. **How** depends on the tracker `/setup-matt-pocock-skills` configured — the tickets are the same either way, only the shape of the blocking edges changes:

- **Local files** → write one file per ticket under `<primary-checkout>/.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). Each file's "Blocked by" lists the numbers/titles it depends on. Use the per-ticket file template below — one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, Linear, …)** → publish one issue per ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. Use the platform's native blocking / sub-issue relationship where it has one; otherwise set each ticket's "Blocked by" to the blocking issues. Apply the `ready-for-agent` triage label unless instructed otherwise — the tickets are agent-grabbable by construction.

Publish blockers first so native edges can reference real IDs. On trackers that assign IDs at creation, publish each ticket with a temporary Workspace ID placeholder, then immediately derive its concrete branch/worktree from the returned ID and update that ticket before publishing the next one. Every final ticket body must contain the concrete **Workspace** section from the policy below.

After publication, replace temporary ordinals in the HTML map with real ticket IDs and links. Reopen the map and verify that map, tracker edges, and ticket workspace instructions agree.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue. Complete when every ticket is `ready-for-agent`, all tracker relationships are verified, and the final visual map uses real IDs/links.

## Workspace policy

- **Sequential ticket:** use the spec integration branch/worktree directly.
- **Parallel ticket:** reserve branch `<integration-branch>-<ticket-id>` and worktree `<repo>/.worktrees/<integration-worktree-slug>-<ticket-id>`.
- Create a parallel lane only when the ticket is unblocked, from the latest local integration commit. Before work starts, verify every blocker commit is present.
- Run concurrent agents only in separate worktrees. Integration remains the merge target and source for new lanes.
- To complete a parallel ticket: validate its lane, merge it locally into the integration branch, validate the integration worktree, remove the lane worktree, and delete the local lane branch.
- Integration and lane branches remain local and are never pushed.
- The final ticket performs full integrated verification and records a post-merge cleanup handoff. The operator who performs the approved integration-branch merge into the default branch then validates the default branch, removes the spec worktree, and deletes the local integration branch. This post-merge cleanup is not a pre-merge acceptance gate for the final implementation ticket.
- Branch merges and cleanup follow normal repository approval rules.

<local-ticket-template>

# <NN> — <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None — can start immediately".

**Status:** ready-for-agent

## Workspace

- **Mode:** integration or parallel lane
- **Branch:** concrete local branch
- **Worktree:** concrete local path
- **Integrates into:** the spec integration branch
- **Remote policy:** local only — never push
- **Completion:** validation, merge target, and required worktree/branch cleanup

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</local-ticket-template>

<issue-template>

## Parent

A reference to the parent issue on the tracker (if the source was an existing issue, otherwise omit this section).

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- A reference to each blocking ticket, or "None — can start immediately".

## Workspace

- **Mode:** integration or parallel lane
- **Branch:** concrete local branch
- **Worktree:** concrete local path
- **Integrates into:** the spec integration branch
- **Remote policy:** local only — never push
- **Completion:** validation, merge target, and required worktree/branch cleanup

</issue-template>

In either form, avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.
