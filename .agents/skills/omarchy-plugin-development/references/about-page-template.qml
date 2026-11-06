/*
 * Structural starter for an About view inside an existing plugin panel.
 * Adapt root bindings, translation keys, URLs, and component properties.
 * Keep the existing panel header in place; insert the About body below it.
 */

// Reuse the existing header button and its position in both views.
Button {
  id: aboutButton
  text: root.viewMode === "about" ? root.tr("metrics") : "v" + root.pluginVersion
  focusable: true
  onClicked: {
    if (root.viewMode === "about") root.showMetrics()
    else root.showAbout()
  }
}

// About body only. The shared panel header and scroll container belong to the
// surrounding panel and stay visible/active in Metrics and About views.
Column {
  id: aboutColumn
  width: contentScroll.width
  spacing: Style.space(14)
  visible: root.viewMode === "about"

  Column {
    width: parent.width
    spacing: Style.space(8)

    Row {
      width: parent.width
      spacing: Style.space(8)

      PanelSectionHeader {
        id: aboutLinksHeader
        width: implicitWidth
        text: root.tr("aboutLinks").toUpperCase()
        foreground: root.foreground
        fontFamily: root.fontFamily
      }

      PanelSectionHeader {
        width: Math.max(0, parent.width - aboutLinksHeader.width - parent.spacing)
        text: "v" + root.pluginVersion
        foreground: root.foreground
        fontFamily: root.fontFamily
        horizontalAlignment: Text.AlignRight
      }
    }

    Column {
      width: parent.width
      spacing: Style.space(4)

      Button {
        width: parent.width
        text: root.tr("aboutChangelog")
        iconText: "\uf15c"
        bordered: true
        leftAlign: true
        foreground: root.foreground
        fontFamily: root.fontFamily
        fontSize: Style.font.body
        verticalPadding: Style.space(6)
        horizontalPadding: Style.space(10)
        focusable: true
        onClicked: Qt.openUrlExternally(root.changelogUrl)
      }

      // Add only links and optional sections supported by this plugin.
    }
  }

  // Optional: PanelSeparator plus relevant settings or diagnostics below links.
}
