// modules/NotifButton.qml
// Left click: toggle our own ControlPanel
// Right click: toggle DND
import QtQuick
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: 42
    hoverable: true

    property bool panelOpen:   false
    property int  unreadCount: 0
    property bool dndActive:   false

    signal togglePanel()

    Process {
        id: countProc
        command: ["swaync-client", "--count"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var n = parseInt(line.trim())
                if (!isNaN(n)) root.unreadCount = n
            }
        }
    }

    Process {
        id: dndProc
        command: ["swaync-client", "--get-dnd"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) { root.dndActive = line.trim() === "true" }
        }
    }

    Process { id: toggleDnd; command: ["swaync-client", "--toggle-dnd"]; running: false }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            countProc.running = true
            dndProc.running   = true
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(m) {
            if (m.button === Qt.LeftButton) root.togglePanel()
            else                            toggleDnd.running = true
        }
    }

    Text {
        id: bellText
        anchors.centerIn: parent
        text: root.dndActive       ? "󰂜"
            : root.panelOpen       ? ""
            : root.unreadCount > 0 ? "󱅫"
            :                        "󰂚"
        font.family:    "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 25
        font.weight:    Font.ExtraBold
        color: root.panelOpen ? "#3b63cf" : "#7cafff"
        scale: root.hovered ? 1.15 : 1.0
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

        SequentialAnimation on rotation {
            running: root.unreadCount > 0 && !root.dndActive && !root.panelOpen
            loops: Animation.Infinite
            NumberAnimation { to:  8; duration: 80 }
            NumberAnimation { to: -8; duration: 80 }
            NumberAnimation { to:  4; duration: 60 }
            NumberAnimation { to: -4; duration: 60 }
            NumberAnimation { to:  0; duration: 40 }
            PauseAnimation  { duration: 4500 }
        }
    }

    Rectangle {
        visible: root.unreadCount > 0 && !root.dndActive
        anchors {
            top:         bellText.top
            right:       bellText.right
            topMargin:   -3
            rightMargin: -5
        }
        width:  Math.max(15, bdg.implicitWidth + 6)
        height: 15
        radius: 8
        color:  "#ff6b6b"

        Text {
            id: bdg
            anchors.centerIn: parent
            text: root.unreadCount > 99 ? "99+" : root.unreadCount.toString()
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 8
            font.weight:    Font.ExtraBold
            color: "white"
        }
    }
}
