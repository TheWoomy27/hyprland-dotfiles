// modules/Battery.qml
// Only visible if a battery is detected. Hides on desktops.
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: brow.implicitWidth + 20

    property int    percent:   0
    property bool   charging:  false
    property bool   hasBattery: false

    // Check for battery on startup
    Process {
        id: detectProc
        command: ["bash", "-c",
            "ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^BAT|^battery' | head -1"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                root.hasBattery = line.trim().length > 0
                if (root.hasBattery) readProc.running = true
            }
        }
    }

    Process {
        id: readProc
        command: ["bash", "-c", [
            "bat=$(ls /sys/class/power_supply/ | grep -iE '^BAT|^battery' | head -1);",
            "cap=$(cat /sys/class/power_supply/$bat/capacity 2>/dev/null || echo 0);",
            "sta=$(cat /sys/class/power_supply/$bat/status  2>/dev/null || echo Unknown);",
            "echo \"$cap:$sta\""
        ].join(" ")]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var parts = line.trim().split(":")
                if (parts.length >= 2) {
                    root.percent  = parseInt(parts[0]) || 0
                    root.charging = parts[1].trim() === "Charging"
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: root.hasBattery
        repeat: true
        triggeredOnStart: false
        onTriggered: readProc.running = true
    }

    function batIcon() {
        if (charging) {
            if (percent >= 90) return "\uf240"   // nf-fa-battery-full  (charging)
            if (percent >= 60) return "\uf241"   // three-quarters
            if (percent >= 40) return "\uf242"   // half
            if (percent >= 15) return "\uf243"   // quarter
            return "\uf243"                      // quarter (low)
        }
        // Discharging
        if (percent >= 90) return "\uf240"       // nf-fa-battery-full
        if (percent >= 60) return "\uf241"       // three-quarters
        if (percent >= 40) return "\uf242"       // half
        if (percent >= 15) return "\uf243"       // quarter
        return "\uf244"                          // nf-fa-battery-empty
    }

    function batColor() {
        if (charging)       return "#7cafff"
        if (percent <= 10)  return "#ff6b6b"
        if (percent <= 25)  return "#ffa94d"
        return "#7cafff"
    }

    visible: root.hasBattery

    RowLayout {
        id: brow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.batIcon()
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: root.batColor()
            Behavior on color { ColorAnimation { duration: 300 } }
        }
        Text {
            text: root.percent + "%"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: root.batColor()
            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }
}
