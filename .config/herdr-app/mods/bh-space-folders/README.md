# Space folders

Folder-aware replacement for Beautiful Herdr's spaces sidebar. Drag spaces into folders, fold groups, create spaces in a folder, and collect spaces automatically with path/name rules. Keeps worktree grouping, machine grouping, colors, and space navigation.

Adapted from [jankeesvw/herdr-space-folders](https://github.com/jankeesvw/herdr-space-folders), itself based on Herdr's shipped `spaces` mod. The adapter renames overlay/key command IDs and preserves Beautiful Herdr's agent-view selection behavior.

Folder state remains in `~/.config/herdr-space-folders.json` and Herdr shared state remains keyed as `space-folders` for compatibility with upstream data. See the repository's [`keys.json`](../../keys.json) for the `beautiful-herdr` navigation bindings.
