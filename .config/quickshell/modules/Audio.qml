// modules/Audio.qml
// Left click: (reserved)  Right click: pavucontrol
// Scroll: adjust volume immediately, then re-read after short delay
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: arow.implicitWidth + 20

    property real   volume:   0.0
    property bool   muted:    false
    property int    volPct:   Math.round(volume * 100)
    property string sinkType: "speaker"

    Process {
        id: volRead
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var m = line.match(/Volume:\s*([\d.]+)/)
                if (m) root.volume = parseFloat(m[1])
                root.muted = line.includes("[MUTED]")
            }
        }
    }

    Process {
        id: sinkCheck
        command: ["bash", "-c",
            "wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -i 'node.description' | head -1"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var lower = line.toLowerCase()
                root.sinkType = (lower.includes("headphone") || lower.includes("headset")
                                 || lower.includes("earphone") || lower.includes("earbuds"))
                                ? "headset" : "speaker"
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            volRead.running  = true
            sinkCheck.running = true
        }
    }

    // Short delay re-read after scroll to get accurate value
    Timer {
        id: refreshTimer
        interval: 150
        onTriggered: volRead.running = true
    }

    Process { id: volUp;    command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]; running: false }
    Process { id: volDown;  command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]; running: false }
    Process { id: volMute;  command: ["wpctl", "set-mute",   "@DEFAULT_AUDIO_SINK@", "toggle"]; running: false }
    Process { id: pavu;     command: ["pavucontrol"]; running: false }

    function volIcon() {
        if (muted || volPct === 0)
            return sinkType === "headset" ? "\udb80\udc7a" : "\uf026"
        if (sinkType === "headset")
            return "\udb80\udc7a"
        if (volPct < 50) return "\uf027"
        return "\uf028"
    }

    RowLayout {
        id: arow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.volIcon()
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: root.muted ? "#6b7fa3" : "#7cafff"
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            text: root.volPct + "%"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: root.muted ? "#6b7fa3" : "#7cafff"
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(m) {
            if (m.button === Qt.RightButton) {
                pavu.running = true
            } else {
                volMute.running = true
                refreshTimer.restart()
            }
        }
        onWheel: function(w) {
            if (w.angleDelta.y > 0) {
                // Optimistically update UI immediately for snappy feel
                root.volume = Math.min(1.5, root.volume + 0.05)
                volUp.running = true
            } else {
                root.volume = Math.max(0.0, root.volume - 0.05)
                volDown.running = true
            }
            refreshTimer.restart()
        }
    }
}
