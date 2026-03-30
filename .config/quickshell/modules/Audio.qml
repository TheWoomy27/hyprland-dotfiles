// modules/Audio.qml
// Icons: nf-fa-volume_off, nf-fa-volume_down, nf-fa-volume_up (fa-volume set)
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: arow.implicitWidth + 20

    property real volume: 0.0
    property bool muted:  false
    property int  volPct: Math.round(volume * 100)

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

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volRead.running = true
    }

    Process { id: volUp;   command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]; running: false }
    Process { id: volDown; command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]; running: false }
    Process { id: volMute; command: ["wpctl", "set-mute",   "@DEFAULT_AUDIO_SINK@", "toggle"]; running: false }

    function volIcon() {
        if (muted || volPct === 0) return "\uf026"   // nf-fa-volume_off
        if (volPct < 50)           return "\uf027"   // nf-fa-volume_down
        return "\uf028"                              // nf-fa-volume_up
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
            color: "#7cafff"
        }
        Text {
            text: root.volPct + "%"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            volMute.running = true
            Qt.callLater(function() { volRead.running = true })
        }
        onWheel: function(w) {
            if (w.angleDelta.y > 0) volUp.running = true
            else volDown.running = true
            Qt.callLater(function() { volRead.running = true })
        }
    }
}
