// modules/BarItem.qml
import QtQuick

Item {
    id: root

    default property alias contentData: inner.data
    property color bgColor:   "#191a2a"
    property bool  hoverable: true
    property bool  hovered:   hoverArea.containsMouse

    implicitHeight: 42

    readonly property int baseGradientDuration: 400
    readonly property real baseGradientSize: implicitHeight
    readonly property int gradientDuration: 400 //Math.round(baseGradientDuration * Math.sqrt(Math.max(1.0, width / Math.max(1.0, baseGradientSize))))
    readonly property int gradientEasing: width > implicitHeight * 3
        ? Easing.Linear
        : Easing.InOutCubic

    property real gradientT: 0.0

    onGradientTChanged: borderCanvas.requestPaint()

    NumberAnimation {
        id: tAnim
        target:   root
        property: "gradientT"
        duration: root.gradientDuration
        easing.type: root.gradientEasing
    }

    onHoveredChanged: {
        if (!hoverable) return
        tAnim.stop()
        tAnim.from = gradientT
        tAnim.to   = hovered ? 1.0 : 0.0
        tAnim.start()
    }

    Canvas {
        id: borderCanvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx   = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var cx    = width  / 2
            var cy    = height / 2
            var len   = height * Math.SQRT2 / 2
            var angle = (Math.PI / 4) + root.gradientT * Math.PI
            var dx    = Math.cos(angle) * len
            var dy    = Math.sin(angle) * len
            var grad  = ctx.createLinearGradient(cx - dx, cy - dy, cx + dx, cy + dy)
            grad.addColorStop(0.0, "#7cafff")
            grad.addColorStop(1.0, "#3b63cf")
            ctx.fillStyle = grad
            ctx.beginPath()
            ctx.moveTo(16, 0)
            ctx.arcTo(width, 0,      width, height, 16)
            ctx.arcTo(width, height, 0,     height, 16)
            ctx.arcTo(0,     height, 0,     0,      16)
            ctx.arcTo(0,     0,      width, 0,      16)
            ctx.closePath()
            ctx.fill()
        }

        onWidthChanged:  requestPaint()
        onHeightChanged: requestPaint()
    }

    Rectangle {
        id: inner
        anchors {
            fill:    parent
            margins: 3
        }
        radius: 13
        color:  root.hovered && root.hoverable
                    ? Qt.lighter(root.bgColor, 1.15)
                    : root.bgColor
        clip: true
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        enabled:      root.hoverable
        hoverEnabled: root.hoverable
        propagateComposedEvents: true
        onClicked: function(mouse) { mouse.accepted = false }
        onPressed: function(mouse) { mouse.accepted = false }
    }
}
