/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2022 Javier O. Cordero Pérez <javiercorderoperez@gmail.com>
*/

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0

import org.kde.kirigami 2.11 as Kirigami
import org.kde.syntaxhighlighting 1.0

import com.cuperino.clipboardinspector.document 1.0

Kirigami.ApplicationWindow {
    id: root

    readonly property string programTitle: i18n("Clipboard Inspector")
    readonly property bool readOnly: true
    readonly property int padding: 0
    //property alias mimeType: document.mimeType

    function loadAboutPage() {
        root.pageStack.layers.clear()
        root.pageStack.layers.push(aboutPageComponent, {})
//         root.pageStack.layers.push(aboutPageComponent, {aboutData: aboutData})
    }
    function paste() {
        //code.text = "";
        //output.text = "";
        document.isNewFile = false
        document.paste();
    }

    title: i18n("Cuperino's %1", root.programTitle)
    minimumWidth: 291
    minimumHeight: minimumWidth
    width: 960
    height: 540

    globalDrawer: Kirigami.GlobalDrawer {
        title: root.programTitle
        titleIcon: "edit-paste"
        isMenu: !root.isMobile
        actions: [
            Kirigami.Action {
                text: i18n("&Save code")
                enabled: !document.isNewFile
                icon.name: "document-save"
                shortcut: StandardKey.Save
                onTriggered: saveDialog.open()
            },
            Kirigami.Action {
                text: i18n("Abou&t") + " " + i18n("Clipboard Inspector") // + aboutData.displayName
                iconName: "help-about"
                onTriggered: loadAboutPage()
            },
            Kirigami.Action {
                visible: !Kirigami.Settings.isMobile
                text: i18n("&Quit")
                iconName: "application-exit"
                shortcut: StandardKey.Quit
                onTriggered: Qt.quit()
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

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
        actions.main: Kirigami.Action {
            text: i18n("Paste")
            icon.name: "edit-paste"
            tooltip: i18n("Paste and decompose clipboard contents")
            shortcut: StandardKey.Paste
            onTriggered: root.paste()
        }
        actions.left: Kirigami.Action {
            text: i18n("Undo")
            icon.name: "edit-undo"
            enabled: code.canUndo && output.canUndo
            shortcut: StandardKey.Undo
            onTriggered: {
                mime.undo()
                code.undo()
                output.undo()
            }
        }
        actions.right: Kirigami.Action {
            text: i18n("Redo")
            icon.name: "edit-redo"
            enabled: code.canRedo && output.canRedo
            shortcut: StandardKey.Redo
            onTriggered: {
                mime.redo()
                code.redo()
                output.redo()
            }
        }
        actions.contextualActions: [
            Kirigami.Action {
                enabled: !document.isNewFile
                text: i18n("Copy contents")
                iconName: "edit-copy"
                shortcut: StandardKey.Copy
                onTriggered: document.copy()
                //{
                    //showPassiveNotification("Not implemented");
                //}
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
                    text: i18n("MIME:")
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
                        text: "Clipboard contents:"
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
                            Keys.onPressed: {
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
                        text: "Content preview:"
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
            selectExisting: false
            defaultSuffix: nameFilters[0]
            nameFilters: [
                i18n("Plain Text (TXT)") + "(*.txt *.text *.TXT *.TEXT)",
                i18n("All Formats") + "(*.*)"
            ]
            selectedNameFilter: nameFilters[0]
            folder: shortcuts.documents
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
