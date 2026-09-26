// modules/Cava.qml
// Shows when audio is playing, hides (after 5s linger) when silent.
// Reveal: left→right (width grows).  Hide: right→left (width shrinks).
// FPS: hardcoded 144 to match monitor refresh rate.
import QtQuick
import Quickshell.Io
import "../services" as Backend

Item {
    id: root
    // Full width when visible
    readonly property int shadowGutter: 2
    readonly property int contentWidth: barCount * (barWidth + barSpacing) - barSpacing + 6
    readonly property int fullWidth: contentWidth + shadowGutter * 2

    Process {
        id: openCava
        command: ["hyprctl", "dispatch", "hl.dsp.exec_cmd(\"[float on; size 1150 646;] kitty -e cava\")"]
        running: false
    }

    // Animate width: 0 when hidden, fullWidth when shown
    implicitHeight: 42 + shadowGutter * 2
    implicitWidth: Backend.CavaService.shouldShow ? fullWidth : 0

    Behavior on implicitWidth {
        NumberAnimation { duration: 500; easing.type: Easing.InOutCubic }
    }

    // Don't take layout space or receive events when fully collapsed
    visible: implicitWidth > 0
    clip: true

    readonly property int barCount:   Backend.CavaService.barCount
    readonly property int barWidth:    3
    readonly property int barSpacing:  2
    readonly property int maxLevel:   Backend.CavaService.maxLevel

    // The actual BarItem — fills the animated width
    BarItem {
        id: inner
        anchors {
            fill: parent
            margins: root.shadowGutter
        }
        hoverable: false

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
                    var lv   = Backend.CavaService.levels[i]
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
                target: Backend.CavaService
                function onLevelsChanged() { canvas.requestPaint() }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: openCava.running = true
    }
}
