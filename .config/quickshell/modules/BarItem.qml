// modules/BarItem.qml
import QtQuick
import QtQuick.Effects

Item {
    id: root

    default property alias contentData: inner.data
    property color bgColor:   "#131421"
    property bool  hoverable: true
    property bool  hovered:   hoverHandler.hovered
    property bool  shadowEnabled: false
    property color shadowColor: "#131421"
    property real  shadowBlur: 0.95
    property real  shadowOpacity: 1000.0
    property real  shadowScale: 1.04
    property real  shadowRingOpacity: 1.0
    property real  shadowRingWidth: 7
    property int   shadowVerticalOffset: 0

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
        id: shadowShape
        anchors.fill: parent
        antialiasing: true
        opacity: root.shadowEnabled ? 1.0 : 0.0
        visible: opacity > 0
        z: -1

        layer.enabled: root.shadowEnabled
        layer.smooth: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.shadowColor
            shadowBlur: root.shadowBlur
            shadowOpacity: root.shadowOpacity
            shadowScale: root.shadowScale
            shadowVerticalOffset: root.shadowVerticalOffset
            shadowHorizontalOffset: 0
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (!root.shadowEnabled) return

            var lw = root.shadowRingWidth
            var inset = lw / 2 + 1
            var r = 16

            ctx.save()
            ctx.globalAlpha = root.shadowRingOpacity
            ctx.strokeStyle = root.shadowColor
            ctx.lineWidth = lw
            ctx.beginPath()
            ctx.moveTo(inset + r, inset)
            ctx.arcTo(width - inset, inset, width - inset, height - inset, r)
            ctx.arcTo(width - inset, height - inset, inset, height - inset, r)
            ctx.arcTo(inset, height - inset, inset, inset, r)
            ctx.arcTo(inset, inset, width - inset, inset, r)
            ctx.closePath()
            ctx.stroke()
            ctx.restore()
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        Connections {
            target: root
            function onShadowEnabledChanged() { shadowShape.requestPaint() }
            function onShadowColorChanged() { shadowShape.requestPaint() }
            function onShadowRingOpacityChanged() { shadowShape.requestPaint() }
            function onShadowRingWidthChanged() { shadowShape.requestPaint() }
        }
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
        anchors {
            fill: parent
            margins: -1
        }
        z: -0.5
        radius: 17
        color: "transparent"
        border.width: 1
        border.color: "#801b1e31"
    }

    Rectangle {
        anchors {
            fill: parent
            margins: -2
        }
        z: -1
        radius: 18
        color: "transparent"
        border.width: 1
        border.color: "#401b1e31"
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

    HoverHandler {
        id: hoverHandler
        enabled:      root.hoverable
    }
}
