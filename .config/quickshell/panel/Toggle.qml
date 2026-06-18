// panel/Toggle.qml
// Reusable gradient-border toggle button. Active = gradient fill (like active workspace).
// Border rotates direction on hover. Animated everything.
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    Layout.minimumWidth: 0

    property string icon:    "\uf111"
    property string label:   "Toggle"
    property bool   active:  false
    property bool   interactive: true
    property int    iconPixelSize: 18
    property real   iconHoverScale: 1.28
    property int    hoverScaleDuration: 600

    signal clicked()

    implicitWidth:  140
    implicitHeight: 56

    // Gradient rotation animation (same as BarItem)
    property real gradientT: 0.0
    property bool hov: hoverArea.containsMouse

    onHovChanged: {
        tAnim.stop()
        tAnim.from = gradientT
        tAnim.to   = hov ? 1.0 : 0.0
        tAnim.start()
    }

    NumberAnimation {
        id: tAnim
        target:   root
        property: "gradientT"
        duration: 400
        easing.type: Easing.InOutCubic
    }

    onGradientTChanged: {
        borderCanvas.requestPaint()
        activeFill.requestPaint()
    }

    // Border canvas
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

    // Active fill (gradient, like active workspace)
    Canvas {
        id: activeFill
        anchors { fill: parent; margins: 3 }
        antialiasing: true
        visible: root.active
        opacity: root.active ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 220; easing.type: Easing.InOutCubic }
        }

        onPaint: {
            var ctx  = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var cx   = width  / 2
            var cy   = height / 2
            var len  = height * Math.SQRT2 / 2
            var angle = (Math.PI / 4) + root.gradientT * Math.PI
            var dx   = Math.cos(angle) * len
            var dy   = Math.sin(angle) * len
            var grad = ctx.createLinearGradient(cx - dx, cy - dy, cx + dx, cy + dy)
            grad.addColorStop(0.0, "#7cafff")
            grad.addColorStop(1.0, "#3b63cf")
            ctx.fillStyle = grad
            ctx.beginPath()
            ctx.moveTo(13, 0)
            ctx.arcTo(width, 0,      width, height, 13)
            ctx.arcTo(width, height, 0,     height, 13)
            ctx.arcTo(0,     height, 0,     0,      13)
            ctx.arcTo(0,     0,      width, 0,      13)
            ctx.closePath()
            ctx.fill()
        }

        onWidthChanged:  requestPaint()
        onHeightChanged: requestPaint()
    }

    // Inactive dark background
    Rectangle {
        anchors { fill: parent; margins: 3 }
        radius: 13
        color:  root.hov && !root.active ? "#2a2d47" : "#1e2030"
        visible: !root.active
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    // Content
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 8

        Text {
            Layout.alignment: Qt.AlignVCenter
            text:  root.icon
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: root.iconPixelSize
            font.weight:    Font.ExtraBold
            color: root.active ? "#191a2a" : "#7cafff"
            Behavior on color { ColorAnimation { duration: 200 } }

            scale: root.hov ? root.iconHoverScale : 1.0
            Behavior on scale { NumberAnimation { duration: root.hoverScaleDuration; easing.type: Easing.OutBack } }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            text:  root.label
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 13
            font.weight:    Font.ExtraBold
            color: root.active ? "#191a2a" : "#7cafff"
            elide: Text.ElideRight
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.clicked()
    }
}
