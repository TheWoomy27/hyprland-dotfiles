// modules/WallpaperSwitcher.qml
// Left click: pick a random wallpaper from Moonlight
// Right click: launch waypaper
import QtQuick
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: 42
    hoverable: true

    Process {
        id: switchProc
        command: ["bash", "-lc",
            "f=$(find \"$HOME/Pictures/Wallpapers/Moonlight\" -type f | shuf -n 1); " +
            "[ -n \"$f\" ] && awww img \"$f\" --transition-type any --transition-fps 144 --transition-duration 1.5"]
        running: false
    }

    Process {
        id: waypaperProc
        command: ["waypaper"]
        running: false
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(m) {
            if (m.button === Qt.LeftButton) switchProc.running = true
            else                            waypaperProc.running = true
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
