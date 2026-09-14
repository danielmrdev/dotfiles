---
name: herdr-broot
description: Open the right-side project file tree with herdr-broot only when the user explicitly asks to open the project panel, project tree, file tree, or project sidebar. Trigger on requests such as "abre panel de proyecto", "quiero ver el árbol de ficheros del proyecto", or "abre el side-panel de proyecto". Do not use for ordinary coding work without an explicit request. Requires running inside Herdr with HERDR_ENV=1 and HERDR_PANE_ID set.
---

# Project Panel

On an explicit project-panel request:

1. Confirm current agent runs inside Herdr:

   ```bash
   test "${HERDR_ENV:-}" = 1 && test -n "${HERDR_PANE_ID:-}"
   ```

   If check fails, tell user project panel requires Herdr. Stop.

2. Resolve project root:

   ```bash
   project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
   ```

3. Open right-side Broot pane without taking focus:

   ```bash
   herdr-broot "$project_root"
   ```

4. Report success and keep working in current agent pane.

Run command once per explicit request. Use exact user request as trigger; ordinary repository exploration does not trigger this skill.
