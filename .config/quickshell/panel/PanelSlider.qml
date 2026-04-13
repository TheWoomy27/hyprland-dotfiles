// panel/PanelSlider.qml
import QtQuick

Item {
    id: root

    property real value:    0.5
    property real minValue: 0.0
    property real maxValue: 1.0

    signal moved(real newValue)

    implicitHeight: 36
    implicitWidth:  200

    readonly property real norm: Math.max(0.0, Math.min(1.0,
        (value - minValue) / Math.max(0.0001, maxValue - minValue)))

    // Track
    Rectangle {
        id: track
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        height: 6; radius: 3; color: "#1a1c2e"
    }

    // Fill — width tracks thumb center position
    Canvas {
        id: fillCanvas
        anchors { left: track.left; verticalCenter: track.verticalCenter }
        width:  Math.max(3, thumb.x + thumb.width / 2)
        height: track.height
        antialiasing: true
        onPaint: {
            var ctx  = getContext("2d"); ctx.clearRect(0, 0, width, height)
            var grad = ctx.createLinearGradient(0, 0, width, 0)
            grad.addColorStop(0.0, "#3b63cf"); grad.addColorStop(1.0, "#7cafff")
            ctx.fillStyle = grad
            ctx.beginPath(); ctx.moveTo(3, 0)
            ctx.arcTo(width, 0,      width, height, 3)
            ctx.arcTo(width, height, 0,     height, 3)
            ctx.arcTo(0,     height, 0,     0,      3)
            ctx.arcTo(0,     0,      width, 0,      3)
            ctx.closePath(); ctx.fill()
        }
        onWidthChanged: requestPaint()
    }

    Rectangle {
        id: thumb
        width: 22; height: 22; radius: 11
        anchors.verticalCenter: track.verticalCenter
        border.color: Qt.rgba(1, 1, 1, 0.2); border.width: 1

        // Binding drives position when NOT dragging.
        // thumbHover.drag.active is the correct property to check.
        Binding {
            target:   thumb
            property: "x"
            value:    root.norm * (track.width - thumb.width)
            when:     !thumbHover.drag.active
        }

        color: thumbHover.drag.active || thumbHover.containsMouse
                   ? Qt.lighter("#7cafff", 1.35) : "#7cafff"
        Behavior on color { ColorAnimation { duration: 100 } }

        // Glow ring
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 10; height: parent.height + 10; radius: width / 2
            color: "transparent"
            border.color: thumbHover.containsMouse ? "#407cafff" : "transparent"
            border.width: 2
            Behavior on border.color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
            id: thumbHover
            anchors { fill: parent; margins: -8 }
            hoverEnabled: true
            cursorShape:  Qt.SizeHorCursor

            drag {
                target:   thumb
                axis:     Drag.XAxis
                minimumX: 0
                maximumX: track.width - thumb.width
            }

            onPositionChanged: {
                if (drag.active) {
                    var n   = thumb.x / Math.max(1, track.width - thumb.width)
                    root.moved(root.minValue + n * (root.maxValue - root.minValue))
                }
            }

            onReleased: {
                var n = thumb.x / Math.max(1, track.width - thumb.width)
                root.moved(root.minValue + n * (root.maxValue - root.minValue))
            }
        }
    }

    // Click on track
    MouseArea {
        anchors { fill: track; margins: -8 }
        cursorShape: Qt.PointingHandCursor
        onClicked: function(mouse) {
            var n = Math.max(0.0, Math.min(1.0, mouse.x / track.width))
            root.moved(root.minValue + n * (root.maxValue - root.minValue))
        }
        onWheel: function(wheel) {
            var delta = wheel.angleDelta.y > 0 ? 0.02 : -0.02
            root.moved(Math.max(root.minValue, Math.min(root.maxValue, root.value + delta)))
        }
    }
}
