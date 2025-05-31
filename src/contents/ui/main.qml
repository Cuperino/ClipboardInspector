/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2022, 2025 Javier O. Cordero Pérez <javiercorderoperez@gmail.com>
*/

import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import org.kde.kirigami as Kirigami
import org.kde.syntaxhighlighting

import com.cuperino.clipboardinspector.document

Kirigami.ApplicationWindow {
    id: root

    readonly property string programTitle: qsTr("Clipboard Inspector")
    readonly property bool readOnly: true
    readonly property int padding: 0

    function loadAboutPage() {
        root.pageStack.layers.clear()
        root.pageStack.layers.push(aboutPageComponent, {})
    }
    function paste() {
        while (mime.canRedo || code.canRedo || output.canRedo) {
            mime.redo()
            code.redo();
            output.redo();
        }
        document.isNewFile = false
        document.paste();
    }

    title: qsTr("Cuperino's %1").arg(root.programTitle)
    minimumWidth: 291
    minimumHeight: minimumWidth
    width: 960
    height: 540

    globalDrawer: Kirigami.GlobalDrawer {
        title: root.programTitle
        titleIcon: "edit-paste"
        actions: [
            Kirigami.Action {
                text: qsTr("&Save Clipboard Contents")
                enabled: !document.isNewFile
                icon.name: "document-save"
                shortcut: StandardKey.Save
                onTriggered: saveDialog.open()
            },
            Kirigami.Action {
                text: qsTr("Abou&t") + " " + qsTr("Clipboard Inspector") // + aboutData.displayName
                icon.name: "help-about"
                onTriggered: loadAboutPage()
            },
            Kirigami.Action {
                visible: !Kirigami.Settings.isMobile
                text: qsTr("&Quit")
                icon.name: "application-exit"
                shortcut: StandardKey.Quit
                onTriggered: Qt.quit()
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {}

    pageStack.globalToolBar.toolbarActionAlignment: Qt.AlignHCenter
    pageStack.initialPage: page

    Settings {
        category: "mainWindow"
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
    }

    Kirigami.Page {
        id: page
        title: root.programTitle
        actions: [
            Kirigami.Action {
                text: qsTr("Inspect Clipboard")
                icon.name: "edit-paste"
                tooltip: qsTr("Paste and decompose clipboard contents")
                shortcut: StandardKey.Paste
                onTriggered: root.paste()
            },
            Kirigami.Action {
                text: qsTr("Previous")
                icon.name: "edit-undo"
                enabled: code.canUndo && output.canUndo
                shortcut: StandardKey.Undo
                onTriggered: {
                    mime.undo()
                    code.undo()
                    output.undo()
                }
            },
            Kirigami.Action {
                text: qsTr("Next")
                icon.name: "edit-redo"
                enabled: code.canRedo && output.canRedo
                shortcut: StandardKey.Redo
                onTriggered: {
                    mime.redo()
                    code.redo()
                    output.redo()
                }
            },
            Kirigami.Action {
                enabled: !document.isNewFile
                text: qsTr("Copy Contents")
                icon.name: "edit-copy"
                shortcut: StandardKey.Copy
                onTriggered: document.copy()
            }
        ]
        ColumnLayout {
            property bool portrait: root.height / root.width > 1
            anchors.fill: parent
            spacing: 6
            GridLayout {
                rows: parent.portrait ? 2 : 1
                columns: parent.portrait ? 1 : 2
                Label {
                    id: labelMime
                    text: qsTr("MIME:")
                }
                TextArea {
                    id: mime
                    Layout.fillWidth: true
                    //width: parent.width
                    textFormat: Qt.PlainText
                    wrapMode: TextArea.Wrap
                    readOnly: root.readOnly
                    text: ""
                    selectByMouse: true
                    font.pixelSize: 12
                    Keys.onPressed: {
                        switch (event.key) {
                            case Qt.Key_V:
                                if (event.modifiers & Qt.ControlModifier)
                                    root.paste()
                        }
                    }
                }
            }
            SplitView {
                orientation: parent.portrait ? Qt.Vertical : Qt.Horizontal
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    //clip: true
                    SplitView.fillHeight: true
                    SplitView.fillWidth: true
                    SplitView.preferredWidth: parent.width / 2
                    SplitView.preferredHeight: parent.height / 2 //- labelCode.height
                    Label {
                        id: labelCode
                        text: "Raw Clipboard Contents:"
                    }
                    Flickable {
                        id: codeFlickable
                        flickableDirection: Flickable.VerticalFlick
                        contentHeight: code.height
                        clip: true
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextArea {
                            id: code
//                             Layout.fillWidth: true
                            width: parent.width
                            //onCursorRectangleChanged: prompter.ensureVisible(cursorRectangle)
                            textFormat: Qt.PlainText
                            wrapMode: TextArea.Wrap
                            readOnly: root.readOnly
                            text: ""
                            selectByMouse: true
                            font.pixelSize: 12
                            Keys.onPressed: (event) => {
                                switch (event.key) {
                                    case Qt.Key_V:
                                        if (event.modifiers & Qt.ControlModifier)
                                            root.paste()
                                }
                            }
                            SyntaxHighlighter {
                                id: highlighter
                                textEdit: code
                                definition: "HTML"
                                // work around for QML not repainting a re-highlighted document...
                                onDefinitionChanged: { code.selectAll(); code.deselect(); }
                                onThemeChanged: { code.selectAll(); code.deselect(); }
                            }
                        }
                        ScrollBar.vertical: ScrollBar {}
                    }
                }
                ColumnLayout {
                    //clip: true
                    SplitView.fillHeight: true
                    SplitView.fillWidth: true
                    SplitView.preferredWidth: parent.width / 2
                    SplitView.preferredHeight: parent.height / 2 //- labelPreview.height
                    Label {
                        id: labelPreview
                        text: "Contents Preview:"
                    }
                    Flickable {
                        flickableDirection: Flickable.VerticalFlick
                        contentHeight: output.height
                        clip: true
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        TextArea {
                            id: output
//                             Layout.fillWidth: true
                            width: parent.width
                            textFormat: Qt.RichText
                            wrapMode: TextArea.Wrap
                            readOnly: root.readOnly
                            text: ""
                            selectByMouse: true
                            font.pixelSize: 12
                            Keys.onPressed: {
                                switch (event.key) {
                                    case Qt.Key_V:
                                        if (event.modifiers & Qt.ControlModifier)
                                            root.paste()
                                }
                            }
                        }
                        ScrollBar.vertical: ScrollBar {}
                    }
                }
            }
        }

        DocumentHandler {
            id: document
            property bool isNewFile: true
            property bool quitOnSave: false
            function newDocument() {
                document.load("qrc:/untitled.html")
                isNewFile = true
            }
            function saveAsDialog() {
                saveDialog.open()
            }
            mimeText: mime.textDocument
            code: code.textDocument
            output: output.textDocument
            //cursorPosition: code.cursorPosition
            //selectionStart: code.selectionStart
            //selectionEnd: code.selectionEnd
            onError: {
                errorDialog.text = message
                errorDialog.visible = true
            }

        }

        FileDialog {
            id: saveDialog
            defaultSuffix: nameFilters[0]
            nameFilters: [
                qsTr("Plain Text (TXT)") + "(*.txt *.text *.TXT *.TEXT)",
                qsTr("All Formats") + "(*.*)"
            ]
            selectedNameFilter.index: 0
            currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
            onAccepted: {
                document.saveAs(saveDialog.fileUrl)
                document.isNewFile = false
                if (document.quitOnSave)
                    Qt.quit()
            }
        }
    }
    // Page Components
    Component {
        id: aboutPageComponent
        AboutPage {}
    }
    // On app load complete
    Component.onCompleted: {
        highlighter.definition = Repository.definitionForFileName("main.qml")
        root.paste()
    }
}
