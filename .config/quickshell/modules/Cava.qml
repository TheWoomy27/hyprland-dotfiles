// modules/Cava.qml
// Shows when audio is playing, hides (after 5s linger) when silent.
// Reveal: left→right (width grows).  Hide: right→left (width shrinks).
// FPS: hardcoded 144 to match monitor refresh rate.
import QtQuick
import Quickshell.Io

Item {
    id: root
    // Full width when visible
    readonly property int fullWidth: barCount * (barWidth + barSpacing) - barSpacing + 6

    property bool audioPlaying: false
    property bool shouldShow:   false

    // Linger 5s after audio stops before hiding
    Timer {
        id: lingerTimer
        interval: 5000
        onTriggered: root.shouldShow = false
    }

    onAudioPlayingChanged: {
        if (audioPlaying) {
            lingerTimer.stop()
            shouldShow = true
        } else {
            lingerTimer.restart()
        }
    }

    // Animate width: 0 when hidden, fullWidth when shown
    implicitHeight: 42
    implicitWidth: shouldShow ? fullWidth : 0

    Behavior on implicitWidth {
        NumberAnimation { duration: 600; easing.type: Easing.InOutCubic }
    }

    // Don't take layout space or receive events when fully collapsed
    visible: implicitWidth > 0
    clip: true

    readonly property int barCount:   24
    readonly property int barWidth:    3
    readonly property int barSpacing:  2
    readonly property int maxLevel:    7

    property var levels: {
        var a = []
        for (var i = 0; i < barCount; i++) a.push(0)
        return a
    }

    // The actual BarItem — fills the animated width
    BarItem {
        id: inner
        anchors.fill: parent
        hoverable: false

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
                    var hasSignal = false
                    for (var i = 0; i < root.barCount; i++) {
                        var level = i < parts.length ? Math.min(parseInt(parts[i]) || 0, root.maxLevel) : 0
                        if (level > 0) hasSignal = true
                        nl.push(level)
                    }
                    root.levels = nl
                    root.audioPlaying = hasSignal
                }
            }
        }

        Canvas {
            id: canvas
            anchors { fill: parent; leftMargin: 3; rightMargin: 3; topMargin: 4; bottomMargin: 4 }
            antialiasing: true

            onPaint: {
                var ctx    = getContext("2d")
                ctx.clearRect(0, 0, width, height)
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
}
