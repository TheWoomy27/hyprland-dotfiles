// panel/TopBar.qml — buttons with hover gradient rotation animation
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    implicitHeight: 52
    implicitWidth:  parent ? parent.width : 380

    property bool   hasBattery:  false
    property int    batPercent:  0
    property bool   batCharging: false

    Process {
        id: batDetect
        command: ["bash", "-c",
            "ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^BAT|^battery' | head -1"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                root.hasBattery = line.trim().length > 0
                if (root.hasBattery) batRead.running = true
            }
        }
    }

    Process {
        id: batRead
        command: ["bash", "-c",
            "bat=$(ls /sys/class/power_supply/ | grep -iE '^BAT|^battery' | head -1);" +
            "echo $(cat /sys/class/power_supply/$bat/capacity 2>/dev/null):$(cat /sys/class/power_supply/$bat/status 2>/dev/null)"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var p = line.trim().split(":")
                if (p.length >= 2) {
                    root.batPercent  = parseInt(p[0]) || 0
                    root.batCharging = p[1].trim() === "Charging"
                }
            }
        }
    }

    Timer { interval: 30000; running: root.hasBattery; repeat: true
            onTriggered: batRead.running = true }

    Process { id: settingsProc;  command: ["hyprctl", "dispatch", "exec", "[workspace special:magic silent] kitty --class hyprmod hyprmod"];  running: false }
    Process { id: lockProc;  command: ["hyprlock"];  running: false }
    Process { id: powerProc; command: ["wlogout"];   running: false }

    function batIcon() {
        if (root.batCharging)      return "\uf0e7"
        if (root.batPercent >= 90) return "\uf240"
        if (root.batPercent >= 60) return "\uf241"
        if (root.batPercent >= 40) return "\uf242"
        if (root.batPercent >= 15) return "\uf243"
        return "\uf244"
    }

    function batColor() {
        if (root.batCharging)      return "#7cafff"
        if (root.batPercent <= 10) return "#ff6b6b"
        if (root.batPercent <= 25) return "#ffa94d"
        return "#7cafff"
    }

    // Battery pill (left)
    Item {
        visible: root.hasBattery
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        implicitWidth:  batRow.implicitWidth + 28
        implicitHeight: 38

        Canvas {
            anchors.fill: parent; antialiasing: true
            onPaint: {
                var ctx = getContext("2d"); ctx.clearRect(0,0,width,height)
                var g = ctx.createLinearGradient(0,0,width,height)
                g.addColorStop(0,"#7cafff"); g.addColorStop(1,"#3b63cf")
                ctx.fillStyle = g
                ctx.beginPath(); ctx.moveTo(13,0)
                ctx.arcTo(width,0,      width,height, 13)
                ctx.arcTo(width,height, 0,    height, 13)
                ctx.arcTo(0,    height, 0,    0,      13)
                ctx.arcTo(0,    0,      width, 0,     13)
                ctx.closePath(); ctx.fill()
            }
        }
        Rectangle {
            anchors { fill: parent; margins: 3 }
            radius: 10; color: "#1e2035"

            RowLayout {
                id: batRow; anchors.centerIn: parent; spacing: 6
                Text {
                    text: root.batIcon()
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 16; font.weight: Font.ExtraBold
                    color: root.batColor()
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
                Text {
                    text: root.batPercent + "%"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 13; font.weight: Font.ExtraBold
                    color: root.batColor()
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
            }
        }
    }

    // Right buttons
    RowLayout {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 10

        TopBarBtn { icon: "";       onClicked: settingsProc.running = true }
        TopBarBtn { icon: ""; onClicked: lockProc.running = true }
        TopBarBtn { icon: ""; dangerColor: true; onClicked: powerProc.running = true }
    }

    component TopBarBtn: Item {
        id: btn
        property string icon:        "\uf111"
        property bool   dangerColor: false
        implicitWidth:  40
        implicitHeight: 40
        signal clicked()

        property bool hov: btnHover.containsMouse

        // Gradient rotation on hover — same pattern as BarItem
        property real gradientT: 0.0
        onHovChanged: {
            gAnim.stop(); gAnim.from = gradientT
            gAnim.to = hov ? 1.0 : 0.0; gAnim.start()
        }
        NumberAnimation {
            id: gAnim; target: btn; property: "gradientT"
            duration: 400; easing.type: Easing.InOutCubic
        }
        onGradientTChanged: borderC.requestPaint()

        Canvas {
            id: borderC; anchors.fill: parent; antialiasing: true
            onPaint: {
                var ctx = getContext("2d"); ctx.clearRect(0,0,width,height)
                var cx=width/2, cy=height/2, len=height*Math.SQRT2/2
                var angle=(Math.PI/4)+parent.gradientT*Math.PI
                var dx=Math.cos(angle)*len, dy=Math.sin(angle)*len
                var g = ctx.createLinearGradient(cx-dx,cy-dy,cx+dx,cy+dy)
                g.addColorStop(0,"#7cafff"); g.addColorStop(1,"#3b63cf")
                ctx.fillStyle = g
                ctx.beginPath(); ctx.moveTo(13,0)
                ctx.arcTo(width,0,      width,height, 13)
                ctx.arcTo(width,height, 0,    height, 13)
                ctx.arcTo(0,    height, 0,    0,      13)
                ctx.arcTo(0,    0,      width, 0,     13)
                ctx.closePath(); ctx.fill()
            }
        }

        Rectangle {
            anchors { fill: parent; margins: 3 }
            radius: 10; color: "#1e2035"
            Rectangle {
                anchors.fill: parent; radius: parent.radius; color: "#ffffff"
                opacity: parent.parent.hov ? 0.07 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
        }

        Text {
            anchors.centerIn: parent; text: icon
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 15; font.weight: Font.ExtraBold
            color: dangerColor && parent.hov ? "#ff6b6b" : "#7cafff"
            scale: parent.hov ? 1.15 : 1.0
            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        }

        MouseArea {
            id: btnHover; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked()
        }
    }
}
