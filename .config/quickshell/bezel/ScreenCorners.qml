import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

// Rounds the physical corners of the display.
//
// The cheapest thing in the whole theme and the one that sells it hardest: with
// square screen corners, rounded windows read as floating rectangles on a
// rectangle. Round the screen and the whole desktop reads as one object.
//
// Drawn as an odd-even fill -- a full-screen rectangle minus a rounded one --
// which leaves exactly the four corner slivers and nothing else.

PanelWindow {
    id: root

    required property var modelData
    property int cornerRadius: 28
    screen: modelData

    WlrLayershell.namespace: "opaline:bezel"
    WlrLayershell.layer: WlrLayer.Overlay

    // Ignore, not zero. `exclusiveZone: 0` still *respects* other surfaces'
    // zones, so the bezel was being pushed below the bar and the top two
    // corners were never drawn. Ignore covers the whole output.
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Empty input region: the overlay is decorative and must never eat a click.
    mask: Region {}

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        asynchronous: false

        ShapePath {
            fillRule: ShapePath.OddEvenFill
            fillColor: "#000000"
            strokeWidth: -1

            PathRectangle {
                width: root.width
                height: root.height
            }
            PathRectangle {
                width: root.width
                height: root.height
                radius: root.cornerRadius
            }
        }
    }
}
