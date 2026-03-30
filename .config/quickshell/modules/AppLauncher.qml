// modules/AppLauncher.qml
// Icon: 󰣇 (nf-md-arch) — U+F0E7 in MD set
// For CachyOS: no nerd font glyph exists. Best option is to use a small
// PNG/SVG via Image {} — place cachyos-logo.png next to this file and
// swap the Text below for:
//   Image { source: "../cachyos-logo.png"; width: 22; height: 22; anchors.centerIn: parent }
import QtQuick
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: 40
    hoverable: true

    Process {
        id: launcher
        command: ["fuzzel"]
        running: false
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: launcher.running = true
    }

    Text {
        anchors.centerIn: parent
        text: "\uf303"   // nf-linux-arch_linux  (keep until CachyOS image available)
        font.family:    "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 20
        font.weight:    Font.ExtraBold
        color: "#7cafff"
        scale: root.hovered ? 1.18 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 160; easing.type: Easing.OutBack }
        }
    }
}
