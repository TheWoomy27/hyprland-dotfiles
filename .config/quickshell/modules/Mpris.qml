// modules/Mpris.qml
// Shows current media: play/pause icon + "Artist - Title"
// Left click: play/pause   Scroll: next/prev
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BarItem {
    id: root
    // BarItem clips inside a 3px border on both sides; include that inset
    // in the module width so short labels do not lose their final glyphs.
    implicitWidth: Math.min(mrow.implicitWidth + 26, maxWidth)

    property string activePlayer: ""
    property string artist:   ""
    property string title:    ""
    property string status:   "Stopped"   // Playing / Paused / Stopped
    property real   maxWidth: 100000
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

    Timer {
        id: refreshTimer
        interval: 120
        onTriggered: if (!metaProc.running) metaProc.running = true
    }

    function playerCommand(action) {
        return root.activePlayer !== ""
            ? ["playerctl", "--player=" + root.activePlayer, action]
            : ["playerctl", action]
    }

    Process {
        id: playPause
        command: root.playerCommand("play-pause")
        running: false
        onRunningChanged: if (!running) refreshTimer.restart()
    }
    Process {
        id: nextTrack
        command: root.playerCommand("next")
        running: false
        onRunningChanged: if (!running) refreshTimer.restart()
    }
    Process {
        id: prevTrack
        command: root.playerCommand("previous")
        running: false
        onRunningChanged: if (!running) refreshTimer.restart()
    }
    Process {
        id: focusSource
        command: ["bash", "-c", [
            "player=\"$1\"",
            "title=\"$2\"",
            "artist=\"$3\"",
            "base=${player%%.*}",
            "case \"$base\" in",
            "    firefox|librewolf|zen|chromium|chrome|brave|vivaldi|opera)",
            "        class_re=\"$base\"",
            "        ;;",
            "    spotify)",
            "        class_re=\"spotify\"",
            "        ;;",
            "    *)",
            "        class_re=\"$base\"",
            "        ;;",
            "esac",
            "addr=$(hyprctl clients -j 2>/dev/null | jq -r --arg class \"$class_re\" --arg title \"$title\" --arg artist \"$artist\" '",
            "    def norm: ascii_downcase;",
            "    [",
            "        .[]",
            "        | .score = (",
            "            (if ((.class // \"\") | norm | contains($class | norm)) then 10 else 0 end) +",
            "            (if (($title | length) > 0 and ((.title // \"\") | norm | contains($title | norm))) then 4 else 0 end) +",
            "            (if (($artist | length) > 0 and ((.title // \"\") | norm | contains($artist | norm))) then 2 else 0 end)",
            "        )",
            "        | select(.score > 0)",
            "    ]",
            "    | sort_by(.score)",
            "    | reverse",
            "    | .[0].address // empty",
            "')",
            "[ -n \"$addr\" ] && hyprctl dispatch \"hl.dsp.focus({ window = 'address:$addr' })\""
        ].join("\n"), "_", root.activePlayer, root.title, root.artist]
        running: false
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: focusSource.running = true
    }

    RowLayout {
        id: mrow
        anchors {
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 6

        PlayerButton {
            icon: "\uf048"
            onClicked: {
                prevTrack.running = true
            }
        }

        PlayerButton {
            icon: root.status === "Playing" ? "\uf04c" : "\uf04b"
            onClicked: {
                playPause.running = true
            }
        }

        PlayerButton {
            icon: "\uf051"
            onClicked: {
                nextTrack.running = true
            }
        }

        // Track label
        Text {
            Layout.fillWidth: true
            text: {
                return root.artist && root.title
                    ? root.artist + " – " + root.title
                    : root.title || root.artist
            }
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 13
            font.weight:    Font.ExtraBold
            color: "#7cafff"
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    WheelHandler {
        onWheel: function(w) {
            if (w.angleDelta.y > 0) prevTrack.running = true
            else                    nextTrack.running = true
        }
    }

    component PlayerButton: Item {
        id: btn

        property string icon: ""
        signal clicked()

        implicitWidth: 18
        implicitHeight: 22
        readonly property bool hovered: area.containsMouse

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 12
            font.weight: Font.ExtraBold
            color: "#7cafff"
            scale: btn.hovered ? 1.8 : 1.3
            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onClicked: btn.clicked()
        }
    }
}
