// modules/AppLauncher.qml
// Left click: vicinae toggle
// Right click: wofi --show drun
import QtQuick
import "../services" as Backend

BarItem {
    id: root
    implicitWidth: 42
    hoverable: true

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(m) {
            if (m.button === Qt.LeftButton) Backend.ActionService.launchVicinae()
            else                            Backend.ActionService.launchWofi()
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
