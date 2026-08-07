---
name: to-spec
description: Turn the current conversation into a spec and publish it to the project issue tracker — no interview, just synthesis of what you've already discussed.
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a spec (you may know this document as a PRD). Do NOT interview the user — synthesize what you already know. A published spec is not complete until it has a verified local integration branch and worktree.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching. Complete when the current behaviour, owning boundaries, and relevant decisions are accounted for.

2. Sketch the seams at which the feature will be tested. Prefer existing seams and use the highest seam possible. Propose a new seam only when existing ones cannot verify the promised behaviour.

Check with the user that these seams match their expectations only when they were not already resolved in the conversation. Complete when every promised behaviour has a verification seam.

3. Draft the spec using the template below. Choose a short feature slug and the repo's conventional branch type (`feat`, `fix`, `chore`, etc.). Complete when the draft contains the workspace policy but no guessed tracker IDs or paths.

4. Resolve the stable spec ID. A passed spec reference, or conversation context that identifies an existing spec, means this run targets that spec. Update it in place and reuse its ID; never create a duplicate. Otherwise publish the draft to the project issue tracker. Do not apply `ready-for-agent` yet. Complete when exactly one tracker spec has the stable reference used for workspace naming.

5. Create the spec's local integration workspace from the repository's default branch:

   - Branch: `<type>/<spec-id>-<feature-slug>` (for example, `feat/50-git-panel`).
   - Worktree: `<repo>/.worktrees/<branch-with-slashes-replaced-by-hyphens>`.
   - Keep the integration branch local. Never push it or any ticket lane derived from it.
   - If the branch or path already exists, verify that it belongs to this spec and is clean. Ask before reusing or changing a conflicting workspace.

   Complete when the branch points at the intended default-branch base, the worktree is clean, and both names resolve exactly as recorded.

6. Replace the draft workspace placeholders with the verified values, update the published spec body, and apply the `ready-for-agent` triage label. Complete when the tracker body, local branch, and worktree agree and the cleanup policy is explicit.

The `/to-tickets` skill consumes this workspace. Sequential tickets integrate directly in it. Parallel tickets use temporary local lanes created from its latest commit, merge back into it, and clean up after verification. After the completed spec is approved and merged into the default branch, validate there, then remove the spec worktree and delete the local integration branch. Merging into the default branch and cleanup require the normal repository approvals.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Implementation Workspace

- **Base branch:** the repository's default branch
- **Integration branch:** the verified local branch for this spec
- **Integration worktree:** the verified `.worktrees/` path for this spec
- **Remote policy:** integration and ticket-lane branches are local only and are never pushed

All ticket work lands in the integration branch. Sequential tickets use its worktree. Tickets that can run concurrently create isolated local branches/worktrees from the latest integration commit and merge back after verification.

After a parallel lane merges into the integration branch, validate the integration worktree, remove the lane worktree, and delete its local branch. After the approved integration branch merges into the default branch, validate the default branch, remove the spec worktree, and delete the local integration branch.

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>
