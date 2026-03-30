// modules/PowerMenu.qml
// Icon: nf-md-power (U+F0425  → \udb80\udc25)
import QtQuick
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: 40
    hoverable: true

    signal toggleMenu()
    property bool menuOpen: false

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleMenu()
    }

    Text {
        anchors.centerIn: parent
        text: "\udb80\udc25"
        font.family:    "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 17
        font.weight:    Font.ExtraBold
        color: root.menuOpen ? "#ff6b6b" : "#7cafff"
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}
