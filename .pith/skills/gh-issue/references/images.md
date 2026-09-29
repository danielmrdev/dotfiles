# Images in GitHub Issues and Comments

Only upload an image when the user explicitly requests it or approves the upload. Confirm the target repository and issue before uploading; issue attachments may be publicly accessible.

## Upload with `gh-attach`

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
