// ControlPanel.qml
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "panel"

PanelWindow {
    id: root

    required property var  screen
    required property bool open
    signal dismissRequested()

    visible: open
    anchors { top: true; right: true; bottom: true }
    implicitWidth: panelWidth + 23
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    readonly property int panelWidth: 390

    // ── Player list — only update model when list actually changes ───────────
    property var _players:      []
    property var _knownPlayers: []

    Process {
        id: listProc
        command: ["playerctl", "--list-all"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var n = line.trim()
                if (n) root._knownPlayers = root._knownPlayers.concat([n])
            }
        }
        onRunningChanged: {
            if (!running) {
                var a = root._knownPlayers.slice().sort().join(",")
                var b = root._players.slice().sort().join(",")
                if (a !== b) root._players = root._knownPlayers.slice()
                root._knownPlayers = []
            }
        }
    }

    Timer {
        interval: 1000
        running: true; repeat: true; triggeredOnStart: true
        onTriggered: { root._knownPlayers = []; listProc.running = true }
    }

    NotificationServer { keepOnReload: true }

    // ── Click outside ─────────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissRequested()
        z: -1
    }

    // ── Outer container with margins ──────────────────────────────────────
    Item {
        anchors {
            top:          parent.top
            right:        parent.right
            bottom:       parent.bottom
            topMargin:    71   // clear bar — adjust to match your bar height + gap
            rightMargin:  20
            bottomMargin: 20
        }
        width: panelWidth

        Rectangle {
            anchors {
                fill: parent
                margins: -1
            }
            z: -0.5
            radius: 21
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
            radius: 22
            color: "transparent"
            border.width: 1
            border.color: "#401b1e31"
        }

        // ── Gradient border canvas ────────────────────────────────────────
        Canvas {
            id: borderCanvas
            anchors.fill: parent
            antialiasing: true
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            onPaint: {
                var ctx   = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var grad  = ctx.createLinearGradient(0, 0, width, height)
                grad.addColorStop(0.0, "#7cafff")
                grad.addColorStop(1.0, "#3b63cf")
                ctx.fillStyle = grad
                var r = 20
                ctx.beginPath()
                ctx.moveTo(r, 0)
                ctx.arcTo(width, 0,      width, height, r)
                ctx.arcTo(width, height, 0,     height, r)
                ctx.arcTo(0,     height, 0,     0,      r)
                ctx.arcTo(0,     0,      width, 0,      r)
                ctx.closePath()
                ctx.fill()

                // Keep the border as a ring so the translucent body does not reveal it.
                var inset = 3
                var innerR = 17
                var innerW = width - inset * 2
                var innerH = height - inset * 2
                ctx.globalCompositeOperation = "destination-out"
                ctx.beginPath()
                ctx.moveTo(inset + innerR, inset)
                ctx.arcTo(inset + innerW, inset,          inset + innerW, inset + innerH, innerR)
                ctx.arcTo(inset + innerW, inset + innerH, inset,          inset + innerH, innerR)
                ctx.arcTo(inset,          inset + innerH, inset,          inset,          innerR)
                ctx.arcTo(inset,          inset,          inset + innerW, inset,          innerR)
                ctx.closePath()
                ctx.fill()
                ctx.globalCompositeOperation = "source-over"
            }
        }

        // ── Inner dark panel ──────────────────────────────────────────────
        Rectangle {
            anchors { fill: parent; margins: 3 }
            radius: 17
            color:  "#cc222436"
            clip:   true

            Flickable {
                anchors.fill: parent
                contentHeight: contentCol.implicitHeight + 16
                clip: true

                Column {
                    id: contentCol
                    width: parent.width
                    topPadding: 16; bottomPadding: 16
                    leftPadding: 16; rightPadding: 16
                    spacing: 18

                    TopBar { width: parent.width - 32 }

                    Rectangle { width: parent.width - 32; height: 1; color: "#2a2d4a" }

                    VolumeSlider     { width: parent.width - 32; panelOpen: root.open }
                    BrightnessSlider { width: parent.width - 32 }

                    Rectangle { width: parent.width - 32; height: 1; color: "#2a2d4a" }

                    ToggleGrid {
                        id: toggleGrid
                        width: parent.width - 32
                        panelOpen: root.open
                    }

                    Rectangle { width: parent.width - 32; height: 1; color: "#2a2d4a" }

                    Column {
                        width: parent.width - 32
                        spacing: 8

                        Text {
                            visible: mediaRep.count > 0
                            text: "Media"
                            font.family:    "JetBrainsMono Nerd Font Propo"
                            font.pixelSize: 13
                            font.weight:    Font.ExtraBold
                            color: "#7cafff"
                        }

                        Repeater {
                            id: mediaRep
                            model: root._players
                            delegate: MediaCard {
                                required property var modelData
                                width:      parent.width
                                playerName: modelData
                            }
                        }

                        Text {
                            visible: mediaRep.count === 0
                            text: "No media playing"
                            font.family:    "JetBrainsMono Nerd Font Propo"
                            font.pixelSize: 12
                            color: "#444a73"
                        }
                    }

                    Rectangle { width: parent.width - 32; height: 1; color: "#2a2d4a" }

                    NotifList { width: parent.width - 32 }
                }
            }
        }
    }
}
