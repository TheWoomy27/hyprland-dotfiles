// modules/Mpris.qml
// Shows current media: play/pause icon + "Artist - Title"
// Left click: play/pause   Scroll: next/prev
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BarItem {
    id: root
    implicitWidth: mrow.implicitWidth + 20

    property string activePlayer: ""
    property string artist:   ""
    property string title:    ""
    property string status:   "Stopped"   // Playing / Paused / Stopped
    property bool   hasMedia: status !== "Stopped" && (artist !== "" || title !== "")
    property bool   _sawMetadata: false

    visible: hasMedia

    Process {
        id: metaProc
        command: ["bash", "-c",
            "fallback=''; " +
            "for p in $(playerctl --list-all 2>/dev/null); do " +
                "st=$(playerctl --player=\"$p\" status 2>/dev/null) || continue; " +
                "artist=$(playerctl --player=\"$p\" metadata artist 2>/dev/null || true); " +
                "title=$(playerctl --player=\"$p\" metadata title 2>/dev/null || true); " +
                "row=$(printf '%s\\t%s\\t%s\\t%s' \"$p\" \"$st\" \"$artist\" \"$title\"); " +
                "[ -z \"$fallback\" ] && fallback=\"$row\"; " +
                "if [ \"$st\" = Playing ]; then printf '%s\\n' \"$row\"; exit 0; fi; " +
            "done; " +
            "[ -n \"$fallback\" ] && printf '%s\\n' \"$fallback\""]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var parts = line.split("\t")
                root._sawMetadata = true
                root.activePlayer = parts[0] ? parts[0].trim() : ""
                root.status = parts[1] ? parts[1].trim() : "Stopped"
                root.artist = parts[2] ? parts[2].trim() : ""
                root.title  = parts[3] ? parts[3].trim() : ""
            }
        }
        onRunningChanged: {
            if (running) {
                root._sawMetadata = false
            } else if (!root._sawMetadata) {
                root.activePlayer = ""
                root.status = "Stopped"
                root.artist = ""
                root.title  = ""
            }
        }
    }

    Timer {
        interval: 250
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: metaProc.running = true
    }

    function playerCommand(action) {
        return root.activePlayer !== ""
            ? ["playerctl", "--player=" + root.activePlayer, action]
            : ["playerctl", action]
    }

    Process { id: playPause; command: root.playerCommand("play-pause"); running: false }
    Process { id: nextTrack; command: root.playerCommand("next");       running: false }
    Process { id: prevTrack; command: root.playerCommand("previous");   running: false }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            playPause.running = true
            Qt.callLater(function() { metaProc.running = true })
        }
        onWheel: function(w) {
            if (w.angleDelta.y > 0) prevTrack.running = true
            else                    nextTrack.running = true
            Qt.callLater(function() { metaProc.running = true })
        }
    }

    RowLayout {
        id: mrow
        anchors.centerIn: parent
        spacing: 6

        // Play/Pause icon
        Text {
            text: root.status === "Playing" ? "\uf04c" : "\uf04b"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 12
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }

        // Track label — max 28 chars, truncated with ellipsis
        Text {
            text: {
                var label = root.artist && root.title
                    ? root.artist + " – " + root.title
                    : root.title || root.artist
                return label.length > 28 ? label.substring(0, 26) + "…" : label
            }
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 13
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
    }
}
