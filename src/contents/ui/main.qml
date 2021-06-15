/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
*/

import QtQuick 2.6
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.13 as Kirigami

Kirigami.ApplicationWindow {
    id: root

    title: i18n("testapp")

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20

    property int counter: 0

    globalDrawer: Kirigami.GlobalDrawer {
        title: i18n("testapp")
        titleIcon: "applications-graphics"
        isMenu: !root.isMobile
        actions: [
            Kirigami.Action {
                text: i18n("Plus One")
                icon.name: "list-add"
                onTriggered: {
                    counter += 1
                }
            },
            Kirigami.Action {
                text: i18n("Quit")
                icon.name: "gtk-quit"
                onTriggered: Qt.quit()
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: page

    Kirigami.Page {
        id: page

        Layout.fillWidth: true

        title: i18n("Main Page")

        actions.main: Kirigami.Action {
            text: i18n("Plus One")
            icon.name: "list-add"
            tooltip: i18n("Add one to the counter")
            onTriggered: {
                counter += 1
            }
        }

        ColumnLayout {
            width: page.width

            anchors.centerIn: parent

            Kirigami.Heading {
                Layout.alignment: Qt.AlignCenter
                text: counter == 0 ? i18n("Hello, World!") : counter
            }

            Controls.Button {
                Layout.alignment: Qt.AlignHCenter
                text: "+ 1"
                onClicked: counter += 1
            }
        }
    }
}
