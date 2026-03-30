// modules/NotifButton.qml
// Icons: nf-md-bell  nf-md-bell_ring  nf-md-bell_off
import QtQuick
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: 40
    hoverable: true

    property int  unreadCount: 0
    property bool dndActive:   false

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

    Process { id: togglePanel; command: ["swaync-client", "--toggle-panel"]; running: false }
    Process { id: toggleDnd;   command: ["swaync-client", "--toggle-dnd"];   running: false }

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
            if (m.button === Qt.LeftButton) togglePanel.running = true
            else                            toggleDnd.running   = true
        }
    }

    Text {
        id: bellText
        anchors.centerIn: parent
        // nf-md-bell_off / nf-md-bell_ring / nf-md-bell
        text: root.dndActive       ? "\udb80\udd51"
            : root.unreadCount > 0 ? "\udb80\udd50"
            :                        "\udb80\udd14"
        font.family:    "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 17
        font.weight:    Font.ExtraBold
        color: "#7cafff"

        SequentialAnimation on rotation {
            running: root.unreadCount > 0 && !root.dndActive
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
