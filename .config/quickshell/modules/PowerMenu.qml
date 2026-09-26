// modules/PowerMenu.qml
// Left click: wlogout  Right click: toggle quickshell popup
import QtQuick
import "../services" as Backend

BarItem {
    id: root
    implicitWidth: 42
    hoverable: true

    signal toggleMenu()
    property bool menuOpen: false

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(m) {
            if (m.button === Qt.LeftButton) Backend.ActionService.openPowerMenu()
            else root.toggleMenu()
        }
    }

    Text {
        anchors.centerIn: parent
        text: "\uf011"
        font.family:    "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 20
        font.weight:    Font.ExtraBold
        color: root.menuOpen ? "#ff6b6b" : "#7cafff"
        scale: root.hovered ? 1.25 : 1.0
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }
    }
}
