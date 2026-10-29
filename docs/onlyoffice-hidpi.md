# ONLYOFFICE HiDPI on Hyprland

## Findings

- GTK scaling is not the main control for this installation. The running `ONLYOFFICE` client is an XWayland window; its binary links Qt 5 and bundled CEF. Its environment includes `GDK_SCALE=1` and `QT_SCALE_FACTOR=1.6`. The user confirmed the Qt factor did not visibly enlarge the editor.
- ONLYOFFICE documents a separate **View tab → Interface scaling** control for editor UI. This is the supported first choice; document zoom changes sheet/page content, not the editor controls. The guide is not explicitly versioned for DesktopEditors 10.0.0 and does not establish exact presets or persistence behavior. [ONLYOFFICE View tab](https://helpcenter.onlyoffice.com/docs/userguides/document_editor/ViewTab.aspx)
- Qt documents `QT_SCALE_FACTOR` as a high-DPI scale factor for Qt applications. Its presence in the process proves delivery, not that the embedded CEF editor UI uses the Qt scale. [Qt 5 High DPI](https://doc.qt.io/qt-5/highdpi.html#environment-variable-reference)
- Hyprland's `xwayland:force_zero_scaling=true` forces XWayland clients to 1× rather than compositor-scaling them to the monitor scale. This setting is active here. Scaling must therefore come from the app; changing it globally would affect all XWayland apps. [Hyprland XWayland settings](https://wiki.hypr.land/Configuring/Variables/#xwayland)
- Current Hyprland gaps are `gaps_out=2`, `gaps_in=4`, with `border_size=3`. Those small compositor gaps do not establish the cause of any larger-looking internal margin; inspect a fresh screenshot after changing editor UI scale.

## Recommended check

1. In an open document, use **View tab → Interface scaling** and choose a larger value shown by the installed build. Do not change document zoom; exact presets are not established by the current user guide.
2. Check whether ribbon text, toolbar controls, and side panels enlarge. If not, capture a fresh screenshot and investigate the editor-specific setting/version.
3. Do not disable `force_zero_scaling` globally unless the user wants all XWayland apps rescaled; it may change sharpness and affects unrelated apps.

## Local evidence

- ONLYOFFICE DesktopEditors 10.0.0-1; active Hyprland client reports `xwayland=true`.
- Both external 3840×2160 monitors use Hyprland scale 1.6.
- `QT_SCALE_FACTOR=1.6` reaches the running app, but user-visible editor UI did not change.
- An undocumented CEF command-line scale switch was investigated and intentionally not retained.

## Sources

- [ONLYOFFICE Document Editor: View tab](https://helpcenter.onlyoffice.com/docs/userguides/document_editor/ViewTab.aspx)
- [Qt 5: High DPI](https://doc.qt.io/qt-5/highdpi.html)
- [Hyprland: XWayland variables](https://wiki.hypr.land/Configuring/Variables/#xwayland)
- [ONLYOFFICE DesktopEditors source](https://github.com/ONLYOFFICE/DesktopEditors)
