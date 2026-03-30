// modules/Workspaces.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

BarItem {
    id: root
    hoverable: false

    property var    screen:     null
    property string screenName: screen ? (screen.name ?? "") : ""

    // All IDs that belong to this screen
    property var baseIds:  screenName === "DP-5" ? [11, 12, 13, 14, 15] : [1, 2, 3, 4, 5]
    property var extraIds: screenName === "DP-5" ? [16, 17, 18, 19]     : [6, 7, 8, 9]
    property var allIds:   baseIds.concat(extraIds)

    // Helper — called from each button so it reads Hyprland.workspaces reactively
    // at the outer scope where reactivity is reliable.
    function isOccupied(wsId) {
        var list = Hyprland.workspaces
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === wsId) return true
        }
        return false
    }

    // Build the list of buttons to show.
    // Rules:
    //   - Always show all baseIds (1-5 or 11-15)
    //   - Show any extraId that has windows (occupied)
    //   - Always show the focused workspace if it belongs to this screen,
    //     even if it is empty (so navigating to ws 6 with no windows shows it)
    property var visibleIds: {
        var ws     = Hyprland.workspaces           // reactive dependency
        var fw     = Hyprland.focusedWorkspace      // reactive dependency
        var result = root.baseIds.slice()
        var extra  = root.extraIds

        // Add occupied extra workspaces
        for (var i = 0; i < extra.length; i++) {
            var eid = extra[i]
            for (var j = 0; j < ws.length; j++) {
                if (ws[j].id === eid) {
                    if (result.indexOf(eid) === -1) result.push(eid)
                    break
                }
            }
        }

        // Always add focused workspace if it's on this screen and not already in list
        if (fw !== null) {
            var fid = fw.id
            if (root.allIds.indexOf(fid) !== -1 && result.indexOf(fid) === -1) {
                result.push(fid)
            }
        }

        result.sort(function(a, b) { return a - b })
        return result
    }

    implicitWidth: wsRow.implicitWidth + 16

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.visibleIds
            delegate: WsButton {
                required property var modelData
                wsId:   modelData
                isBase: root.baseIds.indexOf(modelData) !== -1
            }
        }
    }

    component WsButton: Item {
        id: btn
        property int  wsId:   1
        property bool isBase: true

        readonly property bool active: {
            var fw = Hyprland.focusedWorkspace
            return fw !== null && fw.id === btn.wsId
        }

        // Delegate occupied check to the outer root function so the
        // Hyprland.workspaces reactive binding is definitely in scope.
        readonly property bool occupied: root.isOccupied(btn.wsId)

        readonly property bool hov: btnArea.containsMouse

        implicitWidth:  active ? 38 : 28
        implicitHeight: 28

        // Dim only when: base workspace, not focused, no windows.
        // Extra workspaces are shown only when occupied or focused, so never dimmed.
        opacity: (btn.isBase && !btn.active && !btn.occupied) ? 0.30 : 1.0

        Behavior on implicitWidth {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        // Hover highlight — first so it's behind everything
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color:  btn.hov && !btn.active ? "#ffffff" : "transparent"
            opacity: 0.08
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        // Active: gradient fill
        Canvas {
            id: activeCanvas
            anchors.fill: parent
            visible: btn.active
            antialiasing: true

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

        // Occupied, not active
        Rectangle {
            visible: !btn.active && btn.occupied
            anchors.fill: parent
            radius: height / 2
            color: "#1e2a3a"
        }

        // Base, empty, not active
        Rectangle {
            visible: !btn.active && !btn.occupied
            anchors.fill: parent
            radius: height / 2
            color: "#13142a"
        }

        // Active number — dark over gradient
        Text {
            visible: btn.active
            anchors.centerIn: parent
            text: btn.wsId.toString()
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#191a2a"
        }

        // Inactive number
        Text {
            visible: !btn.active
            anchors.centerIn: parent
            text: btn.wsId.toString()
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: btn.occupied ? "#7cafff" : "#3a4f6a"
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        // MouseArea last = topmost, captures all clicks
        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked:    Hyprland.dispatch("workspace " + btn.wsId)
        }
    }
}
