// modules/Wifi.qml
// Left click: (reserved)  Right click: kitty -e nmtui
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../services" as Backend

BarItem {
    id: root
    // Ethernet: single icon → square. Wifi: icon + signal text → wider.
    implicitWidth: root.connType === "wifi" ? wrow.implicitWidth + 20 : 42
    hoverable: true

    Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    readonly property string connType: Backend.NetworkService.connType
    readonly property string ssid: Backend.NetworkService.ssid
    readonly property int signal: Backend.NetworkService.signalPercent

    Process { id: rightProc; command: ["hyprctl", "dispatch", "hl.dsp.exec_cmd(\"[float; size 1150 646;] kitty -e env NEWT_COLORS='root=#c8d3f5,#222436;border=#131421,#1e2030;window=#c8d3f5,#1e2030;shadow=#222436,#222436;title=#c8d3f5,#222436;button=#c8d3f5,#1e2030;actbutton=#c8d3f5,#444a73;checkbox=black,#c8d3f5;actcheckbox=#c8d3f5,#444a73;entry=#c8d3f5,#1e2030;label=#c8d3f5,#1e2030;listbox=#c8d3f5,#1e2030;actlistbox=#7cafff,#1e2030;textbox=#c8d3f5,#1e2030;acttextbox=#c8d3f5,#131421;helpline=#131421,#1e2030;roottext=#131421,#1e2030;emptyscale=red,#c8d3f5;fullscale=green,#c8d3f5;disabled_entry=gray,#c8d3f5;compactbutton=#c8d3f5,#131421;actsellistbox=#d5def8,#444a73;sellistbox=black,#444a73' nmtui\")"]; running: false }

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
            scale: root.hovered ? 1.5 : 1.2
            Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }
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
