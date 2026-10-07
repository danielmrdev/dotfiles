---
name: omarchy-plugin-development
description: >
  Use when designing, implementing, debugging, validating, or publishing third-party
  Omarchy Shell plugins: Quickshell/QML bar widgets, panels, overlays, menus, services,
  or replacement bars. For installed-system customization or personal built-in plugin
  clones, use the Omarchy customization skill.
---

# Omarchy Plugin Development

Build third-party plugins that fit Omarchy visually and behave correctly in the installed shell. Treat shell APIs and marketplace rules as version-sensitive; verify them before coding.

## 1. Establish scope and sources

Identify the plugin kind, user-visible job, target repository, installed Omarchy version, and whether publishing is in scope. Ask only for decisions that change behavior or visual direction; state assumptions for the rest.

For a genuinely new idea, make a bounded prior-art search across first-party plugins, the current marketplace, and relevant public repositories. Compare the closest matches by behavior, license, maintenance, and compatibility; recommend using, extending, forking, contributing to, or replacing one with a concrete reason. An absent license does not permit copying code or assets. Skip rediscovery for a focused fix or settled design.

Before each plugin task, read the current guides:

- [Develop a Plugin](https://plugins.omarchy.org/develop.html)
- [Publish a Plugin](https://plugins.omarchy.org/publish.html) when release or marketplace listing is in scope
- The shell reference and examples linked from the development guide
- The installed shell's `$OMARCHY_PATH/shell/README.md` and the closest first-party plugin source when available

Use the docs for workflow and the installed shell for the runtime contract. Examples on the `quattro` branch can differ from the user's installed release; verify imports, components, lifecycle, and manifest behavior locally rather than copying stale APIs.

This skill covers plugin code and publication. For installed-user config changes or cloning a built-in widget for personal customization, use the local Omarchy customization skill and its `plugins.md` guide. Keep development in a user-owned plugin checkout; never edit packaged Omarchy source.

## 2. Study a working example first

Choose an existing plugin with the same kind **and** interaction pattern. Read its manifest, entry point, related QML, and helper files before designing. Prefer the official built-in examples linked from the development guide; use the installed source when it matches the target shell version.

Keep the manifest kind aligned with the actual entry point. Follow the documented bar-widget/panel composition when relevant: a widget may load its detail panel internally without declaring a second plugin kind. Keep IDs, `moduleName`, entry-point paths, and lifecycle wiring consistent across files. Use a temporary clone ID only while developing; switch to a permanent namespaced ID and remove clone-only metadata before publishing.

### Stack and implementation boundaries

Default to `manifest.json` plus hosted Quickshell/QML entry points and the installed shell's `qs.Ui`, `qs.Commons`, and services. Use small JavaScript helpers when they fit existing patterns. Add another language, framework, package, or helper process only for a concrete requirement; explain its setup and maintenance cost. Entry points belong inside the long-running shell, never in a separate `ShellRoot` or second Quickshell process.

Decide state ownership before wiring UI: per-widget/per-monitor interaction state, shared service state, persisted user configuration, or external application state. Read [QML implementation standards](references/qml-implementation.md) before editing QML, launching processes, or managing asynchronous state.

## 3. Make visual references explicit

Omarchy plugin documentation supplies working code examples, not a complete visual design system. Do not treat “make it beautiful” as a sufficient design brief. For Daniel's visual preferences, read the [user-selected reference profile](references/visual-style.md) and use it as the default direction unless he specifies otherwise.

For every new visual surface:

1. Find two or three references that match the surface and interaction: user-supplied screenshots/links first, then plugin-gallery previews and first-party Omarchy UI.
2. Inspect the actual images with vision; source code and descriptions alone do not establish visual quality. Record the reference plugin/link and the concrete patterns worth carrying over.
3. Write a short visual brief before implementation: silhouette, hierarchy, information density, spacing rhythm, typography, palette/surfaces, and important interaction states.
4. For a substantial new panel, overlay, menu, or bar, show the references and brief to the user for direction when their preferred style is not already clear. If no useful visual examples exist, ask for one to three screenshots or links before committing to a polished design. Small changes to an existing widget can follow its established style without a separate approval step.
5. Add a one-sentence concept and rough wireframe for substantial surfaces. Derive structure from the plugin's actual job and content; don't reuse the same card/grid/modal composition by default. Treat screenshots as visual evidence, not permission to copy assets or code; retain source links and respect licenses.

Use Omarchy's own components and theme tokens wherever the installed shell provides them. Inspect the current `qs.Ui` and `qs.Commons` APIs (including `Style` and `Color`) instead of inventing replacements. Match the selected theme, existing bar language, and nearby plugin conventions.

### Visual quality gate

Before calling a UI finished, compare a clean runtime screenshot against the chosen references. Check that:

- One clear focal point and readable hierarchy guide the eye; spacing and alignment follow a consistent rhythm.
- Typography, icon weight, control size, surfaces, borders, and corner treatment feel like one system—not unrelated cards assembled together.
- Use Omarchy's semantic theme colors; they adapt automatically when the active theme changes. Status colors communicate state, not decoration. Never hardcode colors sampled from references or add manual theme-switch logic.
- Empty, loading, error, hover, keyboard-focus, and active states are intentional where applicable.
- Content fits at the target shell scale without clipping, awkward gaps, or accidental density. For variable monitor/text scales, check a compact and a larger layout; use installed `Style.space`/fitted-sizing helpers instead of arbitrary fixed dimensions.
- Icons come from the installed Omarchy icon system; motion is purposeful and restrained, never decorative by default.
- Keyboard behavior and pointer behavior agree; focus is visible and Escape/close behavior follows the matching shell pattern.

Revise against the screenshots, not against vague adjectives. For screenshots, frame the plugin surface cleanly and avoid exposing unrelated desktop content. Ask before capturing the user's full desktop.

## 4. Implement for the real shell

Keep the diff narrow and follow the closest working plugin's structure. Reuse shell UI primitives, tokens, services, and lifecycle hooks only after checking their current API. Preserve required bar/panel ownership, anchoring, open/close, keyboard, and IPC behavior for the chosen kind. Build the smallest complete vertical slice first; keep deferred features out of the patch.

Third-party plugins run unsandboxed with the user's permissions. Review every command, dependency, network call, file access, and installer step. Keep privileges and dependencies minimal; do not launch a second Quickshell process for a plugin. Explain meaningful permissions and external setup in the README.

## 5. Validate and inspect

Run the checks documented for the target shell. At minimum, validate the manifest/repository and lint every QML file against the installed shell imports:

```bash
PLUGIN_DIR="$HOME/.config/omarchy/plugins/<plugin-id>"
omarchy plugin validate "$PLUGIN_DIR"
find "$PLUGIN_DIR" -type f -name '*.qml' -print0 \
  | xargs -0 qmllint -I "$OMARCHY_PATH/shell"
```

Check that every entry point exists, uses a safe relative path, and matches its declared kind. Third-party IDs must not use the reserved `omarchy.*` namespace; plugin directories must not contain symlinks.

Validation and linting do not prove the interface works. With user approval before changing their active bar, enabling a plugin, or restarting shell services, test in the actual shell. Follow the development guide's relevant checks: plugin discovery/status, click or summon, close/Escape, shell open/close routes, disable/re-enable, restart, and removal. For data-driven or asynchronous behavior, use deterministic fixtures and cover applicable empty, offline, malformed, partial-failure, stale-completion, retry, and disable/reload states; keep distinct outcomes distinct instead of masking them with generic fallback data. Capture screenshots of meaningful states and compare them with the visual brief. If runtime access is unavailable, say which checks remain unverified.

## 6. Publish only when asked

Before preparing a listing, reread the publishing guide. A submission needs a public GitHub repository, valid root `manifest.json`, README, license, and safe installation/removal instructions; an optimized preview image is optional. Explain dependencies, setup, privileges, services, installers, or remote builds. Automated marketplace validation checks the listing, not plugin security. For repository metadata, preview preparation, commit/tag/push order, form fields, and post-submit checks, use [Marketplace release and submission](references/marketplace-publishing.md).

Use a permanent namespaced plugin ID, remove temporary clone metadata such as `omarchy.clonedFrom`, and verify the final commit. Never push, release, or submit a listing without explicit user approval.

## Completion criteria

Report changed files, validation results, runtime/UI checks, and remaining gaps. A plugin is ready only when its runtime contract validates, relevant QML lints cleanly, behavior checks cover the changed path, required interactions work in the target shell (or are clearly marked unverified), and its visual screenshot has been compared with the agreed references.
