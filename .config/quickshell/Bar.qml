// Bar.qml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "modules"

QtObject {
    id: root
    required property var screen
    property bool powerMenuOpen: false

    property var barWindow: PanelWindow {
        screen: root.screen
        anchors {
            top:   true
            left:  true
            right: true
        }
        implicitHeight: 56
        color: "transparent"

        margins {
            top:    5
            bottom: -12
            left:   10
            right:  10
        }

        // Use a plain Item with anchors so Workspaces can be truly centered
        // independently of the left/right section widths.
        Item {
            anchors.fill: parent

            // Left modules
            RowLayout {
                id: leftRow
                anchors {
                    left:           parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin:     0
                }
                spacing: 7

                AppLauncher   {}
                Cava          {}
                SystemMonitor {}
            }

            // Workspaces — anchored to center regardless of left/right widths
            Workspaces {
                anchors.centerIn: parent
                screen: root.screen
            }

            // Right modules
            RowLayout {
                id: rightRow
                anchors {
                    right:          parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin:    0
                }
                spacing: 7

                Wifi        {}
                Audio       {}
                Clock       {}
                NotifButton {}
                PowerMenu {
                    menuOpen: root.powerMenuOpen
                    onToggleMenu: root.powerMenuOpen = !root.powerMenuOpen
                }
            }
        }
    }

    property var powerPopup: PanelWindow {
        screen:  root.screen
        visible: root.powerMenuOpen
        anchors {
            top:   true
            right: true
        }
        margins {
            top:   62
            right: 10
        }
        implicitWidth:  224
        implicitHeight: popupCol.implicitHeight + 24
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: root.powerMenuOpen = false
            z: -1
        }

        Canvas {
            id: pmCanvas
            anchors.fill: parent
            antialiasing: true
            onPaint: {
                var ctx  = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var grad = ctx.createLinearGradient(0, 0, width, height)
                grad.addColorStop(0.0, "#7cafff")
                grad.addColorStop(1.0, "#3b63cf")
                ctx.fillStyle = grad
                ctx.beginPath()
                ctx.moveTo(12, 0)
                ctx.arcTo(width, 0,      width, height, 12)
                ctx.arcTo(width, height, 0,     height, 12)
                ctx.arcTo(0,     height, 0,     0,      12)
                ctx.arcTo(0,     0,      width, 0,      12)
                ctx.closePath()
                ctx.fill()
            }
            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()
        }

        Rectangle {
            anchors {
                fill:    parent
                margins: 3
            }
            radius: 9
            color:  "#191a2a"

            Column {
                id: popupCol
                anchors {
                    fill:    parent
                    margins: 8
                }
                spacing: 2

                PowerEntry { icon: "\udb80\udced"; label: "Lock";     cmd: ["hyprlock"] }
                PowerEntry { icon: "\udb80\udf48"; label: "Logout";   cmd: ["hyprctl", "dispatch", "exit"] }
                PowerEntry { icon: "\udb80\udc88"; label: "Reboot";   cmd: ["systemctl", "reboot"] }
                PowerEntry { icon: "\udb81\udd74"; label: "Shutdown"; cmd: ["systemctl", "poweroff"]; danger: true }
            }
        }

        component PowerEntry: Item {
            property string icon:   ""
            property string label:  ""
            property var    cmd:    []
            property bool   danger: false

            width:          parent.width
            implicitHeight: 40
            property bool eh: area.containsMouse

            Rectangle {
                anchors {
                    fill:        parent
                    leftMargin:  -2
                    rightMargin: -2
                }
                radius: 8
                color:  eh ? (danger ? "#3d1515" : "#1a2540") : "transparent"
                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }

            Row {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left:           parent.left
                    leftMargin:     12
                }
                spacing: 12

                Text {
                    text: icon
                    font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 15; weight: Font.ExtraBold }
                    color: danger ? "#ff6b6b" : (eh ? "#7cafff" : "#8ba3c7")
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                Text {
                    text: label
                    font { family: "JetBrainsMono Nerd Font Propo"; pixelSize: 14; weight: Font.ExtraBold }
                    color: danger ? "#ff6b6b" : (eh ? "#cdd6f4" : "#8ba3c7")
                }
            }

            Process {
                id: ap
                command: cmd
                running: false
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked: {
                    root.powerMenuOpen = false
                    ap.running = true
                }
            }
        }
    }
}
