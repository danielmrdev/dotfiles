# Plugin About-page pattern

Use this when proposing or building an About view inside a plugin panel. Keep it compact and continuous with the plugin's existing Metrics view.

## Canonical layout

Preserve the existing panel header in both views: same title/identity, icon, alignment, and other controls. Reuse its existing About button as the view toggle:

- In Metrics view, show the current plugin version (for example, `v1.1.1`); click opens About.
- In About view, keep the same button in the same place, label it localized `Metrics`; click returns to the initial dashboard.
- Change only that button's label/state. The shared header remains in place; About content starts below it.

Start the About body with one compact row: `HELP & LINKS` left-aligned, plugin version right-aligned. Put useful support/release links below as full-width actions. Do not add a second header or repeat the icon, plugin name, or developer as a hero—the shared header already identifies the plugin.

```text
┌ [icon] Plugin name                         [v1.1.1] ┐  Metrics view
│                         ... existing dashboard ...   │

┌ [icon] Plugin name                         [Metrics] ┐  About view
│ HELP & LINKS                                  v1.1.1 │
│ [Changelog]                                           │
│ [Marketplace]                                         │
│ [Report issue]                                        │
│ [GitHub]                                              │
│                                                       │
│ [Only relevant settings or diagnostics, if any]      │
└───────────────────────────────────────────────────────┘
```

The version displayed in the header and About section must come from the same QML property. Keep that property synchronized with `manifest.json`. Add optional sections—language controls, settings, or diagnostics—only when the plugin provides those capabilities; place them after Help & Links.

## Implementation

- Add About as a state/view inside the existing panel. Keep the established panel lifecycle, open/close behavior, and keyboard handling. Do not start another Quickshell process or declare another plugin kind.
- Keep the shared header outside the Metrics/About body, visible in both states. Route the existing header button to `showAbout()` or `showMetrics()` based on `viewMode`; reset scrolling and restore focus when switching views.
- Put About content in the existing scroll area. Long content must scroll inside the panel.
- Render the `HELP & LINKS` row with the installed `PanelSectionHeader` (or nearest existing equivalent); allocate the remaining row width to the version label and right-align it.
- Open only fixed, trusted project URLs through the shell-supported external-link API. Localize all visible labels through the plugin translator; see [i18n guidance](i18n.md).
- Use existing panel buttons, spacing, semantic theme colors, and typography. Verify component APIs against the installed shell.
- Keep focus order, selected state, and keyboard activation consistent across both views. Check long translated labels and theme adaptation in the runtime UI.

## Starter and example

Copy and adapt [about-page-template.qml](about-page-template.qml) for the shared toggle and About body; wire it into the target panel's existing header and scroll content. It is a structural starter, not a standalone QML file. Verify all bindings and `qs.Ui` components locally.

For a complete implementation of this pattern, see the [System Info `Panel.qml`](https://github.com/danielmrdev/omarchy-sysinfo/blob/main/Panel.qml). Adapt the navigation and link set to the target plugin; keep its own metadata and actions.
