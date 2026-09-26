// panel/BrightnessSlider.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    implicitWidth:  parent ? parent.width : 300
    implicitHeight: 36

    property int    brightness:    50
    property string _pendingPct:   ""

    Process {
        id: brightRead
        command: ["bash", "-c",
            "cur=$(brightnessctl get 2>/dev/null); max=$(brightnessctl max 2>/dev/null); " +
            "[ -n \"$cur\" ] && echo \"$cur:$max\" || echo \"50:100\""]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var p = line.trim().split(":")
                if (p.length >= 2) {
                    var cur = parseInt(p[0]) || 50
                    var mx  = parseInt(p[1]) || 100
                    root.brightness = Math.round((cur / mx) * 100)
                }
            }
        }
    }

    Process {
        id: brightSet
        command: ["brightnessctl", "set", root._pendingPct]
        running: false
        onRunningChanged: {
            if (!running) root._pendingPct = ""
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightRead.running = true
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "\uf522"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 18
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }

        PanelSlider {
            Layout.fillWidth: true
            value:    root.brightness / 100.0
            minValue: 0.0
            maxValue: 1.0
            onMoved: function(v) {
                root.brightness  = Math.round(v * 100)
                root._pendingPct = root.brightness + "%"
                if (!brightSet.running) brightSet.running = true
            }
        }

        Text {
            text: root.brightness + "%"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 12
            font.weight:    Font.ExtraBold
            color: "#7cafff"
            Layout.minimumWidth: 36
        }
    }
}
