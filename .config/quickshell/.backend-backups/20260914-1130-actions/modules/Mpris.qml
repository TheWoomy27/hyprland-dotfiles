// modules/Mpris.qml
// Shows current media: play/pause icon + "Artist - Title"
// Left click: play/pause   Scroll: next/prev
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../services" as Backend

BarItem {
    id: root
    // BarItem clips inside a 3px border on both sides; include that inset
    // in the module width so short labels do not lose their final glyphs.
    implicitWidth: Math.min(mrow.implicitWidth + 26, maxWidth)

    readonly property var player: Backend.MediaService.active
    readonly property string activePlayer: Backend.MediaService.shortName(player)
    readonly property string artist: player ? player.trackArtist : ""
    readonly property string title: player ? (player.trackTitle || player.identity) : ""
    readonly property string status: !player ? "Stopped" : player.isPlaying ? "Playing" : "Paused"
    property real   maxWidth: 100000
    readonly property bool hasMedia: player !== null && (artist !== "" || title !== "")

    visible: hasMedia

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
                Backend.MediaService.previous(root.player)
            }
        }

        PlayerButton {
            icon: root.status === "Playing" ? "\uf04c" : "\uf04b"
            onClicked: {
                Backend.MediaService.toggle(root.player)
            }
        }

        PlayerButton {
            icon: "\uf051"
            onClicked: {
                Backend.MediaService.next(root.player)
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
            if (w.angleDelta.y > 0) Backend.MediaService.previous(root.player)
            else                    Backend.MediaService.next(root.player)
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
