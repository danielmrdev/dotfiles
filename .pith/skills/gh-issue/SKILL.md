---
name: gh-issue
description: 'Manage GitHub Issues in the repository the user specifies or the current repository — search, create, update, comment, close, delete, labels, and projects.'
invocation:
  model: true
  user: true
---

# GitHub Issues

Use GitHub Issues only when the user or repository workflow identifies GitHub as the tracker. Follow the target repository's issue templates, labels, language, and conventions.

## Resolve the repository

Choose the target in this order: repository explicitly named by the user; repository URL or issue link in the request; current Git repository. For the current repository, resolve it with:

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
```

Set `GH_REPO=owner/repo` from that result and pass `--repo "$GH_REPO"` to commands when scope might otherwise be ambiguous. If no target can be resolved, ask rather than guessing.

## Before writing

- Read the current issue before editing, closing, or commenting on it. Search for duplicates before creating one.
- Inspect the repository's issue templates and existing labels. Use only labels that exist and fit its conventions; do not invent a fixed label taxonomy or create/edit labels unless requested.
- Follow the user's and repository's language and format conventions; examples below are templates, not mandatory wording.
- Ask for explicit approval before an external write the user did not clearly request. A clearly requested create/update/comment/close authorizes only that stated action and scope.
- Deleting issues is destructive: confirm the exact issue and deletion explicitly before proceeding, even when deletion was requested.
- Treat bulk edits, attachments, and project-board changes as separate writes. Do not add them unless requested or included in the user's explicit approval.

## Issue body

Use the repository's template when present. Otherwise adapt this neutral outline:

```markdown
## Goal

## Scope

## Acceptance criteria
- [ ]

## Verification
- [ ]

## Notes
```

For expanded bug, feature, or task templates, see [templates](references/templates.md).

## Search and read

```bash
gh issue list --repo "$GH_REPO" --state open --limit 50
gh issue list --repo "$GH_REPO" --label "bug" --state open
gh issue list --repo "$GH_REPO" --search "cache in:title,body"
gh issue view 12 --repo "$GH_REPO" --json title,body,labels,state,assignees,milestone,comments,url
```

Use `gh search issues` for cross-repository searches. For advanced search syntax, dependencies, sub-issues, custom fields, issue types, or project boards, follow the relevant reference: [search](references/search.md), [dependencies](references/dependencies.md), [sub-issues](references/sub-issues.md), [issue fields](references/issue-fields.md), [issue types](references/issue-types.md), [projects](references/projects.md).

## Create

After checking duplicates, templates, and existing labels, create only the issue the user asked for or the project workflow requires. Do not auto-assign, add labels, or attach local images unless requested or established by the repository's conventions.

```bash
gh issue create --repo "$GH_REPO" \
  --title "Short, actionable title" \
  --body-file /path/to/issue.md
```

Add `--label` or `--assignee` only with an existing, relevant value. Report the resulting issue number and URL. Image upload instructions are in [images](references/images.md); uploading is a separate external write and requires a clear request or approval.

## Work on an issue

1. Read the issue, its comments, labels, and relevant attachments:
   ```bash
   gh issue view 12 --repo "$GH_REPO" --comments
   ```
2. If the task involves repository changes, follow that repository's contributor instructions, branch/worktree policy, and validation requirements. Do not infer a commit, merge, push, or closure policy from the issue number alone.
3. Report verified implementation and integration state. Close the issue only when the user requests closure or the repository workflow authorizes it after verified completion; verify the final state with `gh issue view`.

GitHub may auto-close issues from linked commits or merged changes when configured. Do not assume this happened; verify it on GitHub.

## Modify and comment

Read the current issue first. Make only the requested field changes; preserve unrelated body content.

```bash
gh issue edit 12 --repo "$GH_REPO" --title "Updated title"
gh issue edit 12 --repo "$GH_REPO" --body-file /path/to/updated-issue.md
gh issue edit 12 --repo "$GH_REPO" --add-label "existing-label"
gh issue edit 12 --repo "$GH_REPO" --remove-label "obsolete-label"
gh issue comment 12 --repo "$GH_REPO" --body-file /path/to/comment.md
gh issue reopen 12 --repo "$GH_REPO"
```

Treat each command as an external write. Reopening, changing labels, and editing comments require a clear request or approval just like title/body edits.

## Close or delete

Prefer closing over deleting. Close with a concise reason, and verify the issue state:

```bash
gh issue close 12 --repo "$GH_REPO" --comment "Reason for closure."
gh issue view 12 --repo "$GH_REPO" --json state,url
```

Delete only after the exact issue's number, title, and URL have been confirmed with the user. Deletion uses the GitHub GraphQL API and cannot be undone:

```bash
gh issue view 12 --repo "$GH_REPO" --json id,number,title,url
gh api graphql \
  -f query='mutation($id:ID!){deleteIssue(input:{issueId:$id}){clientMutationId}}' \
  -f id='ISSUE_NODE_ID'
```

## Bulk work

Before a batch, report the target repository, selection criteria, and fields/actions to be changed. Get explicit approval for the batch, inspect affected issues, search for duplicates before creation, and verify the resulting set. Never delete issues as part of a bulk operation.
