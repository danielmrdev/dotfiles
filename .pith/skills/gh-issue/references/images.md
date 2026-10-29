# Images in GitHub Issues and Comments

Only upload an image when the user explicitly requests it or approves the upload. Confirm the target repository, and the issue when attaching to an existing issue or comment; attachments may be publicly accessible.

## Attach images when creating a new issue

Use GitHub CLI's first-party `gh issue create --attach` flag. Attach only the exact image files the user named or approved; creating an issue is not blanket consent to upload local files. Never scan directories or choose additional images. If the request does not clearly authorize those exact files, ask before uploading.

```bash
gh issue create --repo "$GH_REPO" \
  --title "Issue title" \
  --body-file /path/to/issue.md \
  --attach '/path/to/screenshot.png#Settings screen'
```

Repeat `--attach` for each explicitly requested image. These uploads cannot be deleted, and attachments in public repositories may be viewed without authentication; disclose this before proceeding. GitHub CLI can create the issue if at least one attachment succeeds even when another upload fails, then exit non-zero while printing the issue URL. A non-zero exit is not proof that nothing was published, and successful uploads can remain even if issue creation fails: inspect the output, report the URL and failed files, and never blindly retry issue creation. Reconcile the result first to avoid duplicate issues or uploads.

## Attach to an existing issue or comment with `gh-attach`

Use the existing browser-session flow below only for attachments to an existing issue or comment. For new issues, use the native CLI flow above.

[`gh-attach`](https://github.com/Addono/gh-attach) uploads an image through a browser session and returns a GitHub attachment URL.

If `gh-attach` is installed and already authenticated:

```bash
gh attach upload /path/to/image.png --target "OWNER/REPO#123" --format markdown
```

Use `--format json` when you need the URL programmatically. If login is required, ask before starting the browser authentication flow:

```bash
gh attach login
```

Insert the returned Markdown in the issue or comment only when that edit was also requested or approved. Do not upload every local image automatically.

## Browser upload

When `gh-attach` is unavailable, upload through GitHub's web UI:

1. Open the approved issue or comment editor.
2. Attach or paste the approved image.
3. Use the Markdown URL GitHub generates.
4. Submit only after confirming the final issue/comment text and target.

## Capturing screenshots

Use the available browser, desktop, or screenshot tool for the current environment. Check the captured image before attaching it; redact private data and credentials. Do not assume a particular OS, browser path, or screenshot library.

## Avoid repository commits for attachments

Uploading images through the Git Contents API requires creating or updating branches and commits. Avoid that path for ordinary issue attachments. Use it only when the user specifically requests repository-hosted assets and approves the exact files and branch changes.
