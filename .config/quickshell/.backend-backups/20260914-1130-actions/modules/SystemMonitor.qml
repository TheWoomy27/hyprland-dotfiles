// modules/SystemMonitor.qml
// Icons: nf-fa-microchip  nf-md-memory  nf-md-thermometer
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../services" as Backend

BarItem {
    id: root
    implicitWidth: row.implicitWidth + 20

    Process {
        id: btopProc
        command: ["hyprctl", "dispatch", "hl.dsp.exec_cmd(\"[float on; size 1150 646;] kitty -e btop\")"]
        running: false
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: "\uf4bc"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
        Text {
            text: Math.round(Backend.TelemetryService.cpuPercent) + "%"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }

        Text {
            text: "·"
            font.pixelSize: 12
            color: "#2a3a52"
        }

        Text {
            text: "\uefc5"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
        Text {
            text: Math.round(Backend.TelemetryService.ramPercent) + "%"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }

        Text {
            text: "·"
            font.pixelSize: 12
            color: "#2a3a52"
        }

        Text {
            text: "\uf2c9"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
        Text {
            text: Math.round(Backend.TelemetryService.cpuTempC) + "°C"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: btopProc.running = true
    }
}
