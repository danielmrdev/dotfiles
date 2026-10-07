# Marketplace Release and Submission

Use this reference only when the user asks to prepare or publish a plugin. Marketplace rules and issue-form options can change; recheck live sources every time.

## Recheck the live contract

Before release, read the current [publishing guide](https://plugins.omarchy.org/publish.html) and open its **Submit a plugin** issue form. Treat the guide and current form as authoritative; old notes and remembered dropdown values can go stale.

The current form is hosted by the [Omarchy plugin marketplace](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml). Inspect its required fields, category choices, tag choices, and checklist before filling it.

## Prepare the repository

Confirm all of these before submission:

- The plugin has a public GitHub repository with a valid root `manifest.json`.
- Manifest ID is permanent, unique, and namespaced; manifest version matches the release.
- Root `README.md` explains what the plugin does, safe install and removal, dependencies, hardware limits, data access, and privileges.
- Root `LICENSE` documents the plugin's license.
- The repository's GitHub description is concise. GitHub repository topics help discovery, but are separate from marketplace category and tags. Set and verify them separately when requested:

  ```bash
  gh repo edit OWNER/REPO --description "Short plugin summary." \
    --add-topic omarchy --add-topic relevant-topic
  gh repo view OWNER/REPO --json description,repositoryTopics
  ```

- Run the plugin validator, `qmllint` for every QML file, shell syntax checks, and behavior tests. Inspect the final diff and generated assets before staging.

### Preview image

A root `preview.png` is optional; the marketplace detects and optimizes it automatically. A preview makes the listing easier to judge, so include one when a clean, representative image exists.

- Prefer a user-provided or approved screenshot. Confirm ownership or permission for both plugin and preview assets.
- Crop to the plugin surface. Remove desktop bars, unrelated windows, and unused margins. Check visible paths, hostnames, account names, and metric values before making the image public.
- Keep the image readable at marketplace scale, strip unnecessary metadata, and link it from the README with a relative path when useful.

## Release ordering

The marketplace validator checks the repository's current commit. Push the exact validated commit before opening the submission issue.

1. Run final checks and review the staged diff, manifest ID/version, README, license, and preview.
2. Commit and push the release commit to the repository's canonical branch.
3. If the project uses version tags, create and push a tag matching the manifest version (for example, `v1.0.0`). Verify the remote branch and tag point to the intended commit.
4. Submit only after the commit is reachable from GitHub. A matching tag is useful release practice, but is not listed as a marketplace submission requirement by itself.

Do not create a GitHub Release object unless the user asks or the current publishing guide requires it.

## Submit the issue

Use the live form. It currently asks for:

- Public repository URL.
- Category selected from the form.
- One to three marketplace tags selected from the form.
- Optional missing-tag suggestion and maintainer notes.
- Required checkboxes for repository instructions, license/dependencies, asset permission, configuration safety, and understanding that listing approval is not a security review.

Choose category and tags based on the plugin's actual job. Marketplace tags are a controlled vocabulary; do not assume GitHub repository topics are valid marketplace tags. Keep maintainer notes factual: mention permissions, data sources, timeouts, optional dependencies, and hardware-specific behavior.

If the browser needs GitHub authentication, do not handle or request the user's password or token. When an authenticated `gh` CLI is available, the issue can be created with `gh issue create` using the current form's exact headings and required checklist. Use a `[Plugin]: <name> (<id>)` title so marketplace automation can classify it.

The `submission` label may appear asynchronously after issue creation. The marketplace workflow can route a `[Plugin]:` issue before that label is present, then add labels and validation comments. Do not attempt to add labels manually when the account lacks permission, and do not create a duplicate issue just because the label is initially absent. Check the issue timeline and workflow run first.

## Verify the result

After submission, verify the issue URL, open state, selected category/tags, checklist, and automated workflow comments. For example:

```bash
gh issue view ISSUE_NUMBER --repo omacom/omarchy-plugin-marketplace --comments
gh run list --repo omacom/omarchy-plugin-marketplace --workflow route-issue-automation.yml --limit 5
```

A message such as **Ready for listing review** means structural and compatibility checks passed; it does not mean a maintainer approved the listing. An automated security baseline is not a security audit. Report the commit, pushed tag, preview path, issue URL, workflow result, and any remaining maintainer decision.
