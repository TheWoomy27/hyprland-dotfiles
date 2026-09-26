// modules/WallpaperSwitcher.qml
// Left click: pick a random wallpaper from Moonlight
// Right click: launch waypaper
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
            if (m.button === Qt.LeftButton) Backend.ActionService.randomWallpaper()
            else                            Backend.ActionService.openWaypaper()
        }
    }

    Text {
        anchors.centerIn: parent
        text: "󰸉"
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 18
        font.weight: Font.ExtraBold
        color: "#7cafff"
        scale: root.hovered ? 1.5 : 1.2
        Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }
    }
}
