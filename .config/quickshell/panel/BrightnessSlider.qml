// panel/BrightnessSlider.qml — watched backlight state with queued writes
import QtQuick
import QtQuick.Layouts
import "../services" as Backend

Item {
    id: root
    implicitWidth: parent ? parent.width : 300
    implicitHeight: 36

    readonly property int brightness: Backend.BrightnessService.percent

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "\uf522"
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 18
            font.weight: Font.ExtraBold
            color: Backend.BrightnessService.available ? "#7cafff" : "#6b7fa3"
        }

        PanelSlider {
            Layout.fillWidth: true
            enabled: Backend.BrightnessService.available
            opacity: enabled ? 1.0 : 0.45
            value: root.brightness / 100.0
            minValue: 0.01
            maxValue: 1.0
            onMoved: function(value) { Backend.BrightnessService.setPercent(value * 100); }
        }

        Text {
            text: Backend.BrightnessService.available ? root.brightness + "%" : "N/A"
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 12
            font.weight: Font.ExtraBold
            color: Backend.BrightnessService.available ? "#7cafff" : "#6b7fa3"
            Layout.minimumWidth: 36
        }
    }
}
