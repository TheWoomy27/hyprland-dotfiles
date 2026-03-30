// modules/Cava.qml
import QtQuick
import Quickshell.Io

BarItem {
    id: root
    hoverable: false

    readonly property int barCount:   24
    readonly property int barWidth:    3
    readonly property int barSpacing:  2
    readonly property int maxLevel:    7

    // Width: exact bar content with no extra padding — bars touch edges
    implicitWidth: barCount * (barWidth + barSpacing) - barSpacing + 6

    property var levels: {
        var a = []
        for (var i = 0; i < barCount; i++) a.push(0)
        return a
    }

    Process {
        id: cavaProc
        command: ["bash", "-c", "cava -p \"$HOME/.config/quickshell/cava-bar.ini\""]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var t = line.trim()
                if (!t) return
                if (t[t.length - 1] === ";") t = t.slice(0, -1)
                var parts = t.split(";")
                var nl = []
                for (var i = 0; i < root.barCount; i++) {
                    nl.push(i < parts.length ? Math.min(parseInt(parts[i]) || 0, root.maxLevel) : 0)
                }
                root.levels = nl
            }
        }
    }

    Canvas {
        id: canvas
        // No margins — bars touch inner edges
        anchors {
            fill:         parent
            leftMargin:   3
            rightMargin:  3
            topMargin:    4
            bottomMargin: 4
        }
        antialiasing: true

        onPaint: {
            var ctx    = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            // Distribute bars evenly across full width
            var totalW = root.barCount * (root.barWidth + root.barSpacing) - root.barSpacing
            var startX = 0
            for (var i = 0; i < root.barCount; i++) {
                var lv   = root.levels[i]
                var barH = lv === 0 ? 2 : Math.max(2, (lv / root.maxLevel) * height)
                var x    = startX + i * (root.barWidth + root.barSpacing)
                var y    = height - barH
                var grad = ctx.createLinearGradient(x, y, x, height)
                grad.addColorStop(0.0, "#7cafff")
                grad.addColorStop(1.0, "#3b63cf")
                ctx.fillStyle = grad
                ctx.fillRect(x, y, root.barWidth, barH)
            }
        }

        Connections {
            target: root
            function onLevelsChanged() { canvas.requestPaint() }
        }
    }
}
