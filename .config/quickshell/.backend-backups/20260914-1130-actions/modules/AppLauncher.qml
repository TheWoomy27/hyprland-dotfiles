// modules/AppLauncher.qml
// Left click: vicinae toggle
// Right click: wofi --show drun
import QtQuick
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: 42
    hoverable: true

    Process { id: leftProc;  command: ["vicinae", "toggle"]; running: false }
    Process { id: rightProc; command: ["wofi", "--show", "drun"]; running: false }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(m) {
            if (m.button === Qt.LeftButton) leftProc.running = true
            else                            rightProc.running = true
        }
    }

    Image {
        source: "CachyOS_Moonlight.svg"
        width:  28
        height: 28
        anchors.centerIn: parent
        scale: root.hovered ? 1.2 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 500; easing.type: Easing.OutBack }
        }
    }
}
