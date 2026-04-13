// panel/ExpandableToggle.qml
// Two pills with gap. Both halves sample one virtual rotating gradient so the
// motion matches the normal quick toggles while the seam keeps a shared color.
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string icon:     "\uf111"
    property string label:    "Toggle"
    property bool   active:   false
    property bool   expanded: false

    signal toggled()
    signal expandClicked()

    implicitHeight: 48

    readonly property int gap:    6
    readonly property int rightW: 42
    readonly property int leftW:  width - rightW - gap
    readonly property int innerRadius: 5

    property real gradientT: 0.0
    property bool anyHov: leftArea.containsMouse || rightArea.containsMouse

    onAnyHovChanged: {
        gAnim.stop()
        gAnim.from = gradientT
        gAnim.to   = anyHov ? 1.0 : 0.0
        gAnim.start()
    }

    NumberAnimation {
        id: gAnim
        target:   root
        property: "gradientT"
        duration: 400
        easing.type: Easing.InOutCubic
    }

    onGradientTChanged: {
        leftBorder.requestPaint()
        rightBorder.requestPaint()
        leftFill.requestPaint()
        rightFill.requestPaint()
    }
    onWidthChanged: {
        leftBorder.requestPaint()
        rightBorder.requestPaint()
        leftFill.requestPaint()
        rightFill.requestPaint()
    }
    onHeightChanged: {
        leftBorder.requestPaint()
        rightBorder.requestPaint()
        leftFill.requestPaint()
        rightFill.requestPaint()
    }

    // Sample one rotating virtual gradient across both halves, ignoring the
    // visual gap so the split does not interrupt the color ramp.
    function makeGrad(ctx, totalW, seamX, segmentX, height) {
        totalW = Math.max(1, totalW)
        seamX  = Math.max(0, Math.min(totalW, seamX))

        var cx    = totalW / 2 - segmentX
        var cy    = height / 2
        var len   = height * Math.SQRT2 / 2
        var angle = (Math.PI / 4) + root.gradientT * Math.PI
        var g = ctx.createLinearGradient(
            cx - Math.cos(angle) * len,
            cy - Math.sin(angle) * len,
            cx + Math.cos(angle) * len,
            cy + Math.sin(angle) * len)
        g.addColorStop(0.0, "#7cafff")
        g.addColorStop(seamX / totalW, "#4f7ce0")
        g.addColorStop(1.0, "#3b63cf")
        return g
    }

    // ── Left pill ─────────────────────────────────────────────────────────
    Item {
        id: leftPill
        x: 0
        y: 0
        width: root.leftW
        height: root.height

        Canvas {
            id: leftBorder
            anchors.fill: parent
            antialiasing: true
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = root.makeGrad(ctx, root.leftW + root.rightW, root.leftW, 0, height)
                ctx.beginPath()
                ctx.moveTo(14, 0)
                ctx.lineTo(width - root.innerRadius, 0)
                ctx.arcTo(width, 0, width, root.innerRadius, root.innerRadius)
                ctx.lineTo(width, height - root.innerRadius)
                ctx.arcTo(width, height, width - root.innerRadius, height, root.innerRadius)
                ctx.arcTo(0, height, 0, 0, 14)
                ctx.arcTo(0, 0, width, 0, 14)
                ctx.closePath()
                ctx.fill()
            }
        }

        Canvas {
            id: leftFill
            anchors.fill: parent
            anchors.margins: 3
            antialiasing: true
            opacity: root.active ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.InOutCubic }
            }
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = root.makeGrad(ctx, leftFill.width + rightFill.width, leftFill.width, 0, height)
                ctx.beginPath()
                ctx.moveTo(11, 0)
                ctx.lineTo(width - root.innerRadius, 0)
                ctx.arcTo(width, 0, width, root.innerRadius, root.innerRadius)
                ctx.lineTo(width, height - root.innerRadius)
                ctx.arcTo(width, height, width - root.innerRadius, height, root.innerRadius)
                ctx.arcTo(0, height, 0, 0, 11)
                ctx.arcTo(0, 0, width, 0, 11)
                ctx.closePath()
                ctx.fill()
            }
            Connections {
                target: root
                function onActiveChanged() { leftFill.requestPaint() }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            topLeftRadius:    11
            bottomLeftRadius: 11
            topRightRadius:   root.innerRadius
            bottomRightRadius: root.innerRadius
            visible: !root.active
            color:   leftArea.containsMouse ? "#2a2d47" : "#1e2030"
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin:  14
            anchors.rightMargin: 10
            spacing: 8

            Text {
                text: root.icon
                font.family:    "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 16
                font.weight:    Font.ExtraBold
                color: root.active ? "#191a2a" : "#7cafff"
                Behavior on color { ColorAnimation { duration: 200 } }
                scale: leftArea.containsMouse ? 1.12 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 160; easing.type: Easing.OutBack }
                }
            }

            Text {
                text: root.label
                font.family:    "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 13
                font.weight:    Font.ExtraBold
                color: root.active ? "#191a2a" : "#7cafff"
                elide: Text.ElideRight
                Layout.fillWidth: true
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        MouseArea {
            id: leftArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked:    root.toggled()
        }
    }

    // ── Right pill ────────────────────────────────────────────────────────
    Item {
        id: rightPill
        x: root.leftW + root.gap
        y: 0
        width: root.rightW
        height: root.height

        Canvas {
            id: rightBorder
            anchors.fill: parent
            antialiasing: true
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = root.makeGrad(ctx, root.leftW + root.rightW, root.leftW, root.leftW, height)
                ctx.beginPath()
                ctx.moveTo(root.innerRadius, 0)
                ctx.arcTo(width, 0, width, height, 14)
                ctx.arcTo(width, height, 0, height, 14)
                ctx.lineTo(root.innerRadius, height)
                ctx.arcTo(0, height, 0, height - root.innerRadius, root.innerRadius)
                ctx.lineTo(0, root.innerRadius)
                ctx.arcTo(0, 0, root.innerRadius, 0, root.innerRadius)
                ctx.closePath()
                ctx.fill()
            }
        }

        Canvas {
            id: rightFill
            anchors.fill: parent
            anchors.margins: 3
            antialiasing: true
            opacity: root.active ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.InOutCubic }
            }
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = root.makeGrad(ctx, leftFill.width + rightFill.width, leftFill.width, leftFill.width, height)
                ctx.beginPath()
                ctx.moveTo(root.innerRadius, 0)
                ctx.arcTo(width, 0, width, height, 11)
                ctx.arcTo(width, height, 0, height, 11)
                ctx.lineTo(root.innerRadius, height)
                ctx.arcTo(0, height, 0, height - root.innerRadius, root.innerRadius)
                ctx.lineTo(0, root.innerRadius)
                ctx.arcTo(0, 0, root.innerRadius, 0, root.innerRadius)
                ctx.closePath()
                ctx.fill()
            }
            Connections {
                target: root
                function onActiveChanged() { rightFill.requestPaint() }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            topRightRadius:    11
            bottomRightRadius: 11
            topLeftRadius:     root.innerRadius
            bottomLeftRadius:  root.innerRadius
            visible: !root.active
            color:   rightArea.containsMouse ? "#2a2d47" : "#1e2030"
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
            anchors.centerIn: parent
            text: "\uf078"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 11
            font.weight:    Font.ExtraBold
            color: root.active ? "#191a2a" : "#7cafff"
            Behavior on color { ColorAnimation { duration: 200 } }
            scale: rightArea.containsMouse ? 1.12 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 160; easing.type: Easing.OutBack }
            }
            rotation: root.expanded ? 180 : 0
            Behavior on rotation {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            id: rightArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked:    root.expandClicked()
        }
    }
}
