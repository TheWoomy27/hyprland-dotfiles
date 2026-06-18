// modules/Audio.qml
// Profile icon: toggle speaker/mic vs headset/headset-mic
// Volume area left click: mute  Right click: pavucontrol
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
    property string audioProfile: "speaker"
    property string displayedProfileIcon: "󰓃"
    property int    displayedProfileIconSize: 13
    property string profileSwapTargetProfile: "speaker"
    property string profileSwapTargetIcon: "󰓃"
    property int    profileSwapTargetIconSize: 13
    property real   profileSwapScale: 1.0
    readonly property int volumeLabelWidth: 30

    readonly property string speakerSink:   "alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink"
    readonly property string speakerSource: "alsa_input.usb-SteelSeries_SteelSeries_Alias-00.mono-fallback"
    readonly property string headsetSink:   "alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo"
    readonly property string headsetSource: "alsa_input.usb-SteelSeries_Arctis_Nova_7-00.mono-fallback"

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

    Process {
        id: profileRead
        command: ["bash", "-c", "printf '%s\\t%s\\n' \"$(pactl get-default-sink 2>/dev/null)\" \"$(pactl get-default-source 2>/dev/null)\""]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var parts = line.trim().split("\t")
                var sink = parts[0] || ""
                var source = parts[1] || ""
                root.audioProfile = (sink === root.headsetSink || source === root.headsetSource)
                    ? "headset"
                    : "speaker"
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
            profileRead.running = true
        }
    }

    // Short delay re-read after scroll to get accurate value
    Timer {
        id: refreshTimer
        interval: 150
        onTriggered: {
            volRead.running = true
            sinkCheck.running = true
            profileRead.running = true
        }
    }

    Process { id: volUp;    command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]; running: false }
    Process { id: volDown;  command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]; running: false }
    Process { id: volMute;  command: ["wpctl", "set-mute",   "@DEFAULT_AUDIO_SINK@", "toggle"]; running: false }
    Process { id: pavu;     command: ["pavucontrol"]; running: false }
    Process {
        id: profileToggle
        command: ["bash", "-c", root.audioProfile === "headset"
            ? "pactl set-default-sink \"" + root.speakerSink + "\" && pactl set-default-source \"" + root.speakerSource + "\""
            : "pactl set-default-sink \"" + root.headsetSink + "\" && pactl set-default-source \"" + root.headsetSource + "\""]
        running: false
        onRunningChanged: if (!running) refreshTimer.restart()
    }

    function volIcon() {
        if (muted || volPct === 0)
            return sinkType === "headset" ? "\udb80\udc7a" : "\uf026"
        if (sinkType === "headset")
            return "\udb80\udc7a"
        if (volPct < 50) return "\uf027"
        return "\uf028"
    }

    function profileIcon() {
        return profileIconFor(audioProfile)
    }

    function profileIconSize() {
        return profileIconSizeFor(audioProfile)
    }

    function profileIconFor(profile) {
        return profile === "headset" ? "󰋎" : "󰓃"
    }

    function profileIconSizeFor(profile) {
        return profile === "headset" ? 16 : 13
    }

    function swapProfileIcon(profile) {
        if (profileSwapAnim.running && profileSwapTargetProfile === profile)
            return

        profileSwapTargetProfile = profile
        profileSwapTargetIcon = profileIconFor(profile)
        profileSwapTargetIconSize = profileIconSizeFor(profile)

        if (displayedProfileIcon === profileSwapTargetIcon
                && displayedProfileIconSize === profileSwapTargetIconSize)
            return

        profileSwapAnim.restart()
    }

    onAudioProfileChanged: {
        swapProfileIcon(audioProfile)
    }

    Component.onCompleted: {
        displayedProfileIcon = profileIcon()
        displayedProfileIconSize = profileIconSize()
        profileSwapTargetProfile = audioProfile
        profileSwapTargetIcon = displayedProfileIcon
        profileSwapTargetIconSize = displayedProfileIconSize
    }

    SequentialAnimation {
        id: profileSwapAnim
        NumberAnimation {
            target: root
            property: "profileSwapScale"
            to: 0.0
            duration: 170
            easing.type: Easing.InCubic
        }
        ScriptAction {
            script: {
                root.displayedProfileIcon = root.profileSwapTargetIcon
                root.displayedProfileIconSize = root.profileSwapTargetIconSize
            }
        }
        NumberAnimation {
            target: root
            property: "profileSwapScale"
            to: 1.0
            duration: 430
            easing.type: Easing.OutBack
        }
    }

    RowLayout {
        id: arow
        anchors.centerIn: parent
        spacing: 5

        Item {
            id: profileIconBox
            implicitWidth: 20
            implicitHeight: 24
            property real hoverScale: profileArea.containsMouse ? 1.5 : 1.2

            Behavior on hoverScale {
                NumberAnimation { duration: 600; easing.type: Easing.OutBack }
            }

            Text {
                anchors.centerIn: parent
                text: root.displayedProfileIcon
                font.family:    "JetBrainsMono Nerd Font Propo"
                font.pixelSize: root.displayedProfileIconSize
                font.weight:    Font.ExtraBold
                color: "#7cafff"
                scale: root.profileSwapScale * profileIconBox.hoverScale
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            MouseArea {
                id: profileArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.swapProfileIcon(root.audioProfile === "headset" ? "speaker" : "headset")
                    profileToggle.running = true
                }
                onWheel: function(w) { root.adjustVolume(w.angleDelta.y > 0) }
            }
        }

        Item {
            implicitWidth: volRow.implicitWidth
            implicitHeight: 24

            RowLayout {
                id: volRow
                anchors.centerIn: parent
                spacing: 5

                Item {
                    implicitWidth: 18
                    implicitHeight: 24

                    Text {
                        anchors.centerIn: parent
                        text: root.volIcon()
                        font.family:    "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 14
                        font.weight:    Font.ExtraBold
                        color: root.muted ? "#6b7fa3" : "#7cafff"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }
                Item {
                    implicitWidth: root.volumeLabelWidth
                    implicitHeight: 24

                    Text {
                        anchors.fill: parent
                        text: root.volPct + "%"
                        font.family:    "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 14
                        font.weight:    Font.ExtraBold
                        color: root.muted ? "#6b7fa3" : "#7cafff"
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment:   Text.AlignVCenter
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
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
                onWheel: function(w) { root.adjustVolume(w.angleDelta.y > 0) }
            }
        }
    }

    function adjustVolume(up) {
        if (up) {
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
