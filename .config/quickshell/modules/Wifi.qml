// modules/Wifi.qml
// Left click: (reserved)  Right click: kitty -e nmtui
import QtQuick
import QtQuick.Layouts
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

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(m) {
            if (m.button === Qt.RightButton) Backend.ActionService.openNetworkTui()
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
