// modules/Battery.qml
// Only visible if a battery is detected. Hides on desktops.
import QtQuick
import QtQuick.Layouts
import "../services" as Backend

BarItem {
    id: root
    implicitWidth: brow.implicitWidth + 20

    readonly property int percent: Backend.BatteryService.percent
    readonly property bool charging: Backend.BatteryService.charging
    readonly property bool hasBattery: Backend.BatteryService.available

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
