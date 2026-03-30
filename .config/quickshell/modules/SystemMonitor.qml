// modules/SystemMonitor.qml
// Icons: nf-fa-microchip  nf-md-memory  nf-md-thermometer
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: row.implicitWidth + 20

    property real cpuPercent:    0
    property real ramPercent:    0
    property real cpuTempC:      0
    property var  _prevStat:     null
    property int  _memTotal:     0
    property int  _memAvailable: 0

    Process {
        id: cpuProc
        command: ["bash", "-c", "head -1 /proc/stat"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var p     = line.trim().split(/\s+/)
                if (p.length < 5) return
                var idle  = parseInt(p[4]) + (parseInt(p[5]) || 0)
                var busy  = parseInt(p[1]) + parseInt(p[2]) + parseInt(p[3])
                              + (parseInt(p[6]) || 0) + (parseInt(p[7]) || 0)
                var total = idle + busy
                if (root._prevStat) {
                    var dT = total - root._prevStat.total
                    var dI = idle  - root._prevStat.idle
                    root.cpuPercent = dT > 0 ? Math.round((1 - dI / dT) * 100) : 0
                }
                root._prevStat = { total: total, idle: idle }
            }
        }
    }

    Process {
        id: memProc
        command: ["bash", "-c", "grep -E '^(MemTotal|MemAvailable):' /proc/meminfo"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var p = line.trim().split(/\s+/)
                if (p[0] === "MemTotal:")     root._memTotal     = parseInt(p[1])
                if (p[0] === "MemAvailable:") root._memAvailable = parseInt(p[1])
            }
        }
        onRunningChanged: {
            if (!running && root._memTotal > 0)
                root.ramPercent = Math.round((1 - root._memAvailable / root._memTotal) * 100)
        }
    }

    Process {
        id: tempProc
        command: ["bash", "-c", "cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -1"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var v = parseInt(line.trim())
                if (!isNaN(v)) root.cpuTempC = v / 1000
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running  = true
            memProc.running  = true
            tempProc.running = true
        }
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
            text: root.cpuPercent + "%"
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
            text: root.ramPercent + "%"
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
            text: Math.round(root.cpuTempC) + "°C"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
    }
}
