// modules/GradientText.qml
// Renders text with a TL→BR gradient fill using Canvas.
// For vertical-only (Cava bars etc), set horizontal: false.
// Base font size: 14px (≈1rem). Callers can override pixelSize.
import QtQuick

Canvas {
    id: root
    antialiasing: true

    property string displayText: ""
    property int    pixelSize:   14
    property bool   isBold:      true
    // true  = left→right (for most text)
    // false = top→bottom (Cava bars)
    property bool   horizontal:  true

    implicitWidth:  measure.implicitWidth  + 2
    implicitHeight: measure.implicitHeight + 2

    Text {
        id: measure
        visible: false
        text: root.displayText
        font {
            family:    "JetBrainsMono Nerd Font Propo"
            pixelSize: root.pixelSize
            bold:      root.isBold
        }
    }

    onDisplayTextChanged: requestPaint()
    onWidthChanged:       requestPaint()
    onHeightChanged:      requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        var grad
        if (root.horizontal) {
            // Left→right: #7cafff on the left, #3b63cf on the right
            grad = ctx.createLinearGradient(0, 0, width, 0)
        } else {
            // Top→bottom
            grad = ctx.createLinearGradient(0, 0, 0, height)
        }
        grad.addColorStop(0.0, "#7cafff")
        grad.addColorStop(1.0, "#3b63cf")

        ctx.fillStyle    = grad
        ctx.font         = (root.isBold ? "bold " : "")
                         + root.pixelSize
                         + "px 'JetBrainsMono Nerd Font Propo'"
        ctx.textBaseline = "middle"
        ctx.fillText(root.displayText, 1, height / 2 + 1)
    }
}
