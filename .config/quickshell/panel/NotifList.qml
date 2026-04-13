// panel/NotifList.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

Item {
    id: root
    implicitWidth:  parent ? parent.width : 380
    implicitHeight: col.implicitHeight

    readonly property var notifs: {
        var s = NotificationServer.trackedNotifications
        if (!s) return []
        var v = s.values
        if (!v) return []
        return v
    }

    Column {
        id: col
        width: parent.width
        spacing: 0

        // Header
        RowLayout {
            width: parent.width
            height: 36

            Text {
                text: "Notifications"
                font.family:    "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 13
                font.weight:    Font.ExtraBold
                color: "#7cafff"
            }

            Item { Layout.fillWidth: true }

            // Clear all — always visible when there are notifications
            Rectangle {
                visible: root.notifs.length > 0
                width:  clearLbl.implicitWidth + 20
                height: 26
                radius: 13
                color:  "#1e2035"

                Rectangle {
                    anchors.fill: parent; radius: parent.radius
                    color: "#ffffff"
                    opacity: clrHov.containsMouse ? 0.07 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                Text {
                    id: clearLbl
                    anchors.centerIn: parent
                    text: "\uf2ed  Clear all"
                    font.family:    "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 11
                    font.weight:    Font.Bold
                    color: "#7cafff"
                }

                MouseArea {
                    id: clrHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        var n = root.notifs
                        for (var i = 0; i < n.length; i++) n[i].expire()
                    }
                }
            }
        }

        // Empty state
        Item {
            visible: root.notifs.length === 0
            width:   parent.width
            height:  56
            Text {
                anchors.centerIn: parent
                text: "No notifications"
                font.family:    "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 12
                color: "#444a73"
            }
        }

        // Cards
        Column {
            width: parent.width
            spacing: 6

            Repeater {
                model: root.notifs
                delegate: NotifCard {
                    required property var modelData
                    notification: modelData
                    width: parent.width
                }
            }
        }
    }

    component NotifCard: Item {
        required property var notification

        implicitHeight: cardInner.implicitHeight + 20
        clip: true

        Behavior on implicitHeight {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        property bool hov: cardHov.containsMouse

        Rectangle {
            anchors.fill: parent; radius: 14
            color: "#1e2035"

            Rectangle {
                anchors.fill: parent; radius: parent.radius
                color: "#ffffff"
                opacity: hov ? 0.04 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Rectangle {
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: 3; radius: 1; color: "#7cafff"
            }

            Column {
                id: cardInner
                anchors { fill: parent; margins: 14; leftMargin: 18 }
                spacing: 4

                RowLayout {
                    width: parent.width
                    Text {
                        text: notification.appName || ""
                        font.family:    "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 10; font.weight: Font.Bold
                        color: "#5a7090"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "\uf00d"
                        font.family:    "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 10
                        color: xHov.containsMouse ? "#ff6b6b" : "#3a4f6a"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        MouseArea {
                            id: xHov; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notification.expire()
                        }
                    }
                }

                Text {
                    visible: (notification.summary || "") !== ""
                    text:    notification.summary || ""
                    width:   parent.width
                    font.family:    "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 13; font.weight: Font.ExtraBold
                    color: "#cdd6f4"; wrapMode: Text.WordWrap
                }

                Text {
                    visible: (notification.body || "") !== ""
                    text:    notification.body || ""
                    width:   parent.width
                    font.family:    "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 11; color: "#b4c2f0"
                    wrapMode: Text.WordWrap; maximumLineCount: 3; elide: Text.ElideRight
                }

                RowLayout {
                    visible: notification.actions && notification.actions.length > 0
                    width: parent.width; spacing: 6
                    Repeater {
                        model: notification.actions
                        delegate: Rectangle {
                            required property var modelData
                            height: 26; width: aLbl.implicitWidth + 16; radius: 8
                            color: aHov.containsMouse ? "#2a3a5a" : "#1a2035"
                            Behavior on color { ColorAnimation { duration: 100 } }
                            Text {
                                id: aLbl; anchors.centerIn: parent
                                text: modelData.text || modelData.identifier
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 10; font.weight: Font.Bold; color: "#7cafff"
                            }
                            MouseArea {
                                id: aHov; anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor; onClicked: modelData.invoke()
                            }
                        }
                    }
                }
            }
        }

        MouseArea { id: cardHov; anchors.fill: parent; hoverEnabled: true }
    }
}
