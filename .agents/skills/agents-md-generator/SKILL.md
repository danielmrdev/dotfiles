---
name: agents-md-generator
description: Generate small, durable AGENTS.md files using progressive disclosure.
---

# AGENTS.md Generator

Use this skill when creating, reviewing, or refactoring an `AGENTS.md` file for a project used with Pi or other coding agents. The goal is a small, high-signal context file that gives an agent enough orientation to start work without consuming the instruction budget or becoming stale. Do not turn the root file into a complete project manual.

## Core rules

1. Keep the root `AGENTS.md` as small as possible.
2. Include only guidance relevant to every task in that project scope.
3. Prefer capabilities and stable concepts over file paths and detailed directory maps.
4. Use progressive disclosure: move domain-specific guidance to focused Markdown files and link to them.
5. In monorepos, keep the root file about the repository and put package-specific guidance in nested `AGENTS.md` files.
6. Never add generic filler such as “write clean code”, obvious language advice, or speculative rules.
7. Never add a rule merely because an agent made one mistake. First check whether the rule is specific, necessary, non-contradictory, and still true.

## What belongs in the root file

Include, when applicable:

- One sentence describing what the project is.
- The package manager, when it is not npm or is otherwise non-obvious.
- Non-standard build, typecheck, lint, or test commands needed for normal work.
- A small number of facts that genuinely apply to every task.
- Links to focused documentation for language, testing, API, build, deployment, or package-specific conventions.

Do not include:

- A full file-system catalogue or paths likely to move.
- Language-specific conventions that matter only for some files.
- Long generated inventories, dependency lists, or copied tool documentation.
- Instructions that duplicate the agent's normal capabilities.
- Vague preferences with no checkable effect.

## Procedure

1. Inspect the repository before writing. Identify the project purpose, package manager, top-level build/typecheck/test commands, monorepo boundaries, and existing `AGENTS.md`, `CLAUDE.md`, or documentation. Completion criterion: every proposed root-file fact has a source in the repository or is explicitly marked for confirmation.
2. Read any existing instruction files in full. List contradictions, stale paths, duplicated rules, vague rules, and rules that are not global. Completion criterion: each existing instruction is classified as keep, move, rewrite, confirm, or delete.
3. Ask the user about contradictions or consequential choices before silently choosing between conflicting instructions. Do not invent project policy. Completion criterion: no unresolved contradiction is hidden in the generated file.
4. Design the smallest useful documentation tree. Move domain-specific instructions to focused files such as `docs/TYPESCRIPT.md`, `docs/TESTING.md`, `docs/API.md`, or package-level `AGENTS.md`. Use links from the root file as breadcrumbs. Completion criterion: every moved rule has one clear destination and every link resolves.
5. Write or update the root `AGENTS.md` with a one-sentence project description, non-obvious package manager, essential commands, and only universally applicable guidance. Completion criterion: the root contains no rule that applies only to a domain or package.
6. For a monorepo, add or update nested `AGENTS.md` files only where scope changes. Keep each file focused on its directory and link to deeper documentation instead of repeating the root. Completion criterion: each package-level rule is relevant to all work in that package.
7. Validate commands and links. Check package scripts, executable names, working directories, and referenced files against the repository. Completion criterion: every documented command is real and every relative documentation link resolves.
8. Review the result for instruction budget and staleness. Remove redundant, obvious, speculative, path-heavy, or overly forceful wording. Completion criterion: the root is short enough to read in one sitting and contains no unnecessary catalogue.

## Recommended root template

```markdown
# Project Context

This is [one-sentence description of the project].

## Tooling

- Use [package manager] for dependencies and scripts.
- Build: `[command]`
- Typecheck: `[command]`
- Test: `[command]`

## Guidance

- [Only genuinely global project rule.]
- For [domain] conventions, see [linked document].
- For package-specific guidance, see the package's `AGENTS.md`.
```

Omit empty sections and commands. Do not preserve this template's headings when they add no information.

## Monorepo layout

Use this division of responsibility:

- Root `AGENTS.md`: repository purpose, workspace/package manager, shared commands, navigation.
- Package `AGENTS.md`: package purpose, stack, package-specific commands, and local constraints.
- Focused docs: detailed TypeScript, testing, API, build, deployment, or domain guidance.

Remember that Pi concatenates applicable context files. Repeating root instructions at every level wastes context and increases the chance of drift.

## Refactoring prompt

When the user asks to refactor an existing file, use this checklist:

- Find contradictions and ask about each material conflict.
- Keep only the project description, non-obvious package manager, non-standard commands, and truly global rules in the root.
- Group the rest into focused documents or nested `AGENTS.md` files.
- Create links from the root to those documents.
- Flag redundant, vague, obvious, stale, and speculative rules for deletion.
- Report what moved, what was removed, and what still needs user confirmation.

## Pitfalls

- Do not use an initialization script that generates a comprehensive root file by default.
- Do not document directory structure as if it were permanent.
- Do not use “always” or all-caps enforcement when a precise, scoped statement is enough.
- Do not claim a command works without checking the repository scripts or running it when safe.
- Do not overwrite an existing intentional rule without showing the conflict and asking when the choice is consequential.
- `AGENTS.md` is the conventional filename. Pi also loads `CLAUDE.md`; use a symlink only when the project deliberately supports both tools.

## Verification

Before finishing, verify:

- The root file has one clear project description.
- Package manager and documented commands match repository configuration.
- Every root rule applies to every task at that scope.
- Domain-specific material is linked rather than copied into the root.
- Nested files are limited to the directories whose scope they describe.
- All Markdown links and referenced files resolve.
- No contradiction, stale path, generic filler, or unverified command remains.
- Show the final file list and the validation result to the user.

Source: Matt Pocock, “A Complete Guide To AGENTS.md”, https://www.aihero.dev/a-complete-guide-to-agents-md
