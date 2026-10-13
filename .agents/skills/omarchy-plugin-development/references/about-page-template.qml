/*
 * Copy-and-adapt starter: About-view block from Taskwarrior Time Panel.qml.
 * Copyright (c) 2026 DataArchitectPro; licensed under MIT.
 * Full license notice: taskwarrior-time-MIT-LICENSE.txt
 * Source: https://github.com/DataArchitectPro/taskwarrior-time/blob/master/Panel.qml
 * Insert into the target plugin's existing panel; adapt root bindings, strings,
 * metadata, URLs, actions, and qs.Ui components to that plugin and shell version.
 */
        // About view — hero + sections (links / language / debug)
        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 0
          visible: root.viewMode === "about"

          Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: aboutBody.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            Column {
              id: aboutBody
              width: parent.width
              spacing: Style.space(16)
              topPadding: Style.space(8)
              bottomPadding: Style.space(16)

              PanelHero {
                width: parent.width
                title: root.tr("aboutTitle")
                detail: "v" + root.pluginVersion
                meta: root.tr("aboutDeveloper") + " · " + root.tr("aboutDeveloperName")
                foreground: root.foreground
                fontFamily: root.fontFamily
                iconComponent: Component {
                  Text {
                    textFormat: Text.PlainText
                    text: "\uf0ae"
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.display
                  }
                }
              }

              PanelSeparator { foreground: root.foreground }

              Column {
                width: parent.width
                spacing: Style.space(8)

                PanelSectionHeader {
                  text: root.tr("aboutLinks").toUpperCase()
                  foreground: root.foreground
                  fontFamily: root.fontFamily
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
                    onClicked: Qt.openUrlExternally(root.changelogUrl)
                  }
                  Button {
                    width: parent.width
                    text: root.tr("aboutMarketplace")
                    iconText: "\uf07a"
                    bordered: true
                    leftAlign: true
                    foreground: root.foreground
                    fontFamily: root.fontFamily
                    fontSize: Style.font.body
                    verticalPadding: Style.space(6)
                    horizontalPadding: Style.space(10)
                    onClicked: Qt.openUrlExternally(root.marketplaceUrl)
                  }
                  Button {
                    width: parent.width
                    text: root.tr("aboutNewIssue")
                    iconText: "\uf071"
                    bordered: true
                    leftAlign: true
                    foreground: root.foreground
                    fontFamily: root.fontFamily
                    fontSize: Style.font.body
                    verticalPadding: Style.space(6)
                    horizontalPadding: Style.space(10)
                    onClicked: Qt.openUrlExternally(root.newIssueUrl)
                  }
                  Button {
                    width: parent.width
                    text: root.tr("aboutGithub")
                    iconText: "\uf09b"
                    bordered: true
                    leftAlign: true
                    foreground: root.foreground
                    fontFamily: root.fontFamily
                    fontSize: Style.font.body
                    verticalPadding: Style.space(6)
                    horizontalPadding: Style.space(10)
                    onClicked: Qt.openUrlExternally(root.githubUrl)
                  }
                }
              }

              PanelSeparator { foreground: root.foreground }

              Column {
                width: parent.width
                spacing: Style.space(8)

                PanelSectionHeader {
                  text: root.tr("uiLanguage").toUpperCase()
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                }

                Row {
                  spacing: Style.space(4)

                  Button {
                    text: root.tr("uiLanguageSystem")
                    selected: root.uiLanguage === "system"
                    foreground: root.foreground
                    fontFamily: root.fontFamily
                    fontSize: Style.font.caption
                    verticalPadding: Style.space(2)
                    horizontalPadding: Style.space(8)
                    onClicked: root.setUiLanguage("system")
                  }
                  Button {
                    text: root.tr("uiLanguageRu")
                    selected: root.uiLanguage === "ru"
                    foreground: root.foreground
                    fontFamily: root.fontFamily
                    fontSize: Style.font.caption
                    verticalPadding: Style.space(2)
                    horizontalPadding: Style.space(8)
                    onClicked: root.setUiLanguage("ru")
                  }
                  Button {
                    text: root.tr("uiLanguageEn")
                    selected: root.uiLanguage === "en"
                    foreground: root.foreground
                    fontFamily: root.fontFamily
                    fontSize: Style.font.caption
                    verticalPadding: Style.space(2)
                    horizontalPadding: Style.space(8)
                    onClicked: root.setUiLanguage("en")
                  }
                  Button {
                    text: root.tr("uiLanguageEs")
                    selected: root.uiLanguage === "es"
                    foreground: root.foreground
                    fontFamily: root.fontFamily
                    fontSize: Style.font.caption
                    verticalPadding: Style.space(2)
                    horizontalPadding: Style.space(8)
                    onClicked: root.setUiLanguage("es")
                  }
                }
              }

              PanelSeparator { foreground: root.foreground }

              Column {
                width: parent.width
                spacing: Style.space(8)

                PanelSectionHeader {
                  text: root.tr("debugLog").toUpperCase()
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                }

                Toggle {
                  width: parent.width
                  label: root.debugLogging ? root.tr("debugLogOn") : root.tr("debugLogOff")
                  description: root.debugLogPath || "~/.local/share/taskwarrior-time/debug.log"
                  checked: root.debugLogging
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  titleSize: Style.font.body
                  descriptionSize: Style.font.caption
                  onClicked: root.setDebugLogging(!root.debugLogging)
                }

                Button {
                  width: parent.width
                  text: root.tr("aboutOpenLogFolder")
                  iconText: "\uf07b"
                  bordered: true
                  leftAlign: true
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  fontSize: Style.font.body
                  verticalPadding: Style.space(6)
                  horizontalPadding: Style.space(10)
                  onClicked: root.openDebugLogFolder()
                }

                Button {
                  width: parent.width
                  text: root.tr("aboutClearLogs")
                  iconText: "\uf1f8"
                  bordered: true
                  leftAlign: true
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                  fontSize: Style.font.body
                  verticalPadding: Style.space(6)
                  horizontalPadding: Style.space(10)
                  onClicked: root.clearDebugLogs()
                }

                Text {
                  textFormat: Text.PlainText
                  width: parent.width
                  text: root.tr("debugLogHint")
                  color: root.dim
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  wrapMode: Text.WordWrap
                }
              }
            }
          }
        }
      }

