// modules/Workspaces.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

BarItem {
    id: root
    hoverable: false

    property var    screen:     null
    property string screenName: screen ? (screen.name ?? "") : ""

    property var baseIds:  screenName === "DP-5" ? [11, 12, 13, 14, 15] : [1, 2, 3, 4, 5]
    property var extraIds: screenName === "DP-5" ? [16, 17, 18, 19]     : [6, 7, 8, 9]
    property var allIds:   baseIds.concat(extraIds)

    // Count windows per workspace directly from toplevels — fully reactive,
    // updates whenever any window opens, closes, or moves.
    readonly property var occupiedMap: {
        var occ = {}
        var tls = Hyprland.toplevels.values
        for (var i = 0; i < tls.length; i++) {
            var ws = tls[i].workspace
            if (ws !== null && ws !== undefined)
                occ[ws.id] = true
        }
        return occ
    }

    property var visibleIds: {
        var occ    = root.occupiedMap
        var fw     = Hyprland.focusedWorkspace
        var result = root.baseIds.slice()
        var extra  = root.extraIds

        for (var i = 0; i < extra.length; i++) {
            var eid = extra[i]
            if (occ[eid] && result.indexOf(eid) === -1)
                result.push(eid)
        }

        if (fw !== null && fw !== undefined) {
            var fid = fw.id
            if (root.allIds.indexOf(fid) !== -1 && result.indexOf(fid) === -1)
                result.push(fid)
        }

        result.sort(function(a, b) { return a - b })
        return result
    }

    // Animate module width when extra workspaces appear/disappear
    implicitWidth: wsRow.implicitWidth + 16
    Behavior on implicitWidth {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.visibleIds
            delegate: WsButton {
                required property var modelData
                wsId:       modelData
                isBase:     root.baseIds.indexOf(modelData) !== -1
                isOccupied: root.occupiedMap[modelData] ?? false
                isActive:   Hyprland.focusedWorkspace !== null
                            && Hyprland.focusedWorkspace !== undefined
                            && Hyprland.focusedWorkspace.id === modelData
            }
        }
    }

    component WsButton: Item {
        id: btn

        property int  wsId:       1
        property bool isBase:     true
        property bool isOccupied: false
        property bool isActive:   false

        readonly property bool hov: btnArea.containsMouse

        // Both active and inactive use the same animation duration/easing
        // so the total module width stays constant during workspace switching.
        implicitWidth:  isActive ? 40 : 28
        implicitHeight: 28
        opacity:        (isBase && !isActive && !isOccupied) ? 0.30 : 1.0

        Behavior on implicitWidth {
            NumberAnimation { duration: 220; easing.type: Easing.InOutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        // Hover highlight — uniform for all non-active buttons
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color:  (btn.hov && !btn.isActive) ? "#7cafff" : "transparent"
            opacity: 0.12
            Behavior on color   { ColorAnimation { duration: 120 } }
        }

        // Active gradient fill — opacity-animated so it fades in/out
        Canvas {
            id: activeCanvas
            anchors.fill: parent
            antialiasing: true
            // Always rendered, fades in/out — this creates the smooth transition
            opacity: btn.isActive ? 1.0 : 0.0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.InOutCubic }
            }

            onPaint: {
                var ctx  = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var r    = height / 2
                var grad = ctx.createLinearGradient(0, 0, width, 0)
                grad.addColorStop(0.0, "#7cafff")
                grad.addColorStop(1.0, "#3b63cf")
                ctx.fillStyle = grad
                ctx.beginPath()
                ctx.moveTo(r, 0)
                ctx.arcTo(width, 0,      width, height, r)
                ctx.arcTo(width, height, 0,     height, r)
                ctx.arcTo(0,     height, 0,     0,      r)
                ctx.arcTo(0,     0,      width, 0,      r)
                ctx.closePath()
                ctx.fill()
            }

            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()
        }

        // Base background — same colour regardless of occupied/empty
        // Occupied distinction is via text colour only
        Rectangle {
            visible: !btn.isActive
            anchors.fill: parent
            radius: height / 2
            color: "#191a2a"
        }

        // Active number
        Text {
            visible: btn.isActive
            anchors.centerIn: parent
            text: btn.wsId.toString()
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#191a2a"
            scale: 1.0
        }

        // Inactive number with hover scale
        Text {
            visible: !btn.isActive
            anchors.centerIn: parent
            text: btn.wsId.toString()
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: btn.isOccupied ? "#7cafff" : "#3a4f6a"
            scale: btn.hov ? 1.2 : 1.0
            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked:    Hyprland.dispatch("workspace " + btn.wsId)
        }
    }
}
