// modules/Wifi.qml
// Left click: (reserved)  Right click: kitty -e nmtui
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BarItem {
    id: root
    // Ethernet: single icon → square. Wifi: icon + signal text → wider.
    implicitWidth: root.connType === "wifi" ? wrow.implicitWidth + 20 : 42
    hoverable: true

    Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    property string connType: "none"
    property string ssid:     ""
    property int    signal:   0

    Process { id: rightProc; command: ["kitty", "-e", "nmtui"]; running: false }

    Process {
        id: netProc
        command: ["bash", "-c", [
            "wifi=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes' | head -1);",
            "if [ -n \"$wifi\" ]; then echo \"wifi:$wifi\";",
            "else",
            "  eth=$(nmcli -t -f TYPE,STATE dev 2>/dev/null | grep '^ethernet:connected' | head -1);",
            "  if [ -n \"$eth\" ]; then echo \"ethernet\"; else echo \"none\"; fi;",
            "fi"
        ].join(" ")]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                line = line.trim()
                if (line.startsWith("wifi:yes:")) {
                    var rest  = line.slice(9)
                    var colon = rest.lastIndexOf(":")
                    root.ssid     = colon > 0 ? rest.slice(0, colon) : rest
                    root.signal   = colon > 0 ? (parseInt(rest.slice(colon + 1)) || 0) : 0
                    root.connType = "wifi"
                } else if (line === "ethernet") {
                    root.connType = "ethernet"
                    root.ssid     = ""
                    root.signal   = 0
                } else {
                    root.connType = "none"
                    root.ssid     = ""
                    root.signal   = 0
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(m) {
            if (m.button === Qt.RightButton) rightProc.running = true
        }
    }

    RowLayout {
        id: wrow
        anchors.centerIn: parent
        spacing: 5

        Text {
            visible: root.connType === "wifi"
            text: "\uf1eb"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
            scale: root.hovered ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        }
        Text {
            visible: root.connType === "wifi"
            text: root.signal + "%"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }

        Text {
            visible: root.connType === "ethernet"
            text: "\udb80\ude00"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 18
            font.weight:    Font.ExtraBold
            color: "#7cafff"
            scale: root.hovered ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        }

        Text {
            visible: root.connType === "none"
            text: "\uf1eb"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#ff6b6b"
        }
    }

    Rectangle {
        visible: root.hovered && root.connType !== "none"
        anchors { bottom: parent.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
        width:  ttText.implicitWidth + 16
        height: 26
        radius: 6
        color:  "#191a2a"
        border.color: "#3b63cf"
        border.width: 1
        z: 100
        Text {
            id: ttText
            anchors.centerIn: parent
            text: root.connType === "wifi" ? root.ssid + "  ·  " + root.signal + "%" : "Ethernet"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 11
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
    }
}
