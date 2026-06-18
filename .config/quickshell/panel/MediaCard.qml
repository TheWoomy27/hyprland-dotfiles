// panel/MediaCard.qml
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    implicitWidth:  parent ? parent.width : 300
    implicitHeight: 166
    height: implicitHeight

    property string playerName: ""
    property string title:      "Unknown"
    property string artist:     ""
    property string artUrl:     ""
    property string status:     "Stopped"
    property int    position:   0
    property int    length:     0
    property real   seekTarget: 0
    property bool   seekPending: false

    readonly property bool isPlaying: status === "Playing"
    readonly property bool hasDuration: length > 0
    readonly property bool hasTimeline: hasDuration || status !== "Stopped"
    readonly property real progress: length > 0
        ? Math.max(0.0, Math.min(1.0, position / length))
        : 0.0

    // Local tick keeps the progress smooth without hammering playerctl.
    Timer {
        interval: 1000
        running:  root.isPlaying
        repeat:   true
        onTriggered: {
            if (root.length <= 0 || root.position < root.length)
                root.position += 1
        }
    }

    Process {
        id: metaProc
        command: ["playerctl", "--player=" + root.playerName, "metadata",
                  "--format", "{{title}}\t{{artist}}\t{{status}}\t{{mpris:artUrl}}\t{{position}}\t{{mpris:length}}"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var p = line.split("\t")
                var t = p[0] ? p[0].trim() : ""

                root.title  = t !== "" ? t : "Unknown"
                root.artist = p[1] ? p[1].trim() : ""
                root.status = p[2] ? p[2].trim() : "Stopped"
                root.artUrl = p[3] ? p[3].trim() : ""

                var posRaw = p[4] ? parseInt(p[4]) : 0
                var lenRaw = p[5] ? parseInt(p[5]) : 0
                var pos    = posRaw > 0 ? Math.round(posRaw / 1000000) : 0
                var len    = lenRaw > 0 ? Math.round(lenRaw / 1000000) : 0

                root.length = len
                if (!root.seekPending && (Math.abs(pos - root.position) > 2 || !root.isPlaying))
                    root.position = pos
            }
        }
        onRunningChanged: {
            if (!running && root.title === "")
                root.title = "Unknown"
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!metaProc.running) metaProc.running = true
    }

    Timer {
        id: seekHoldTimer
        interval: 1200
        onTriggered: {
            root.seekPending = false
            if (!metaProc.running)
                metaProc.running = true
        }
    }

    Process { id: shuffleP; command: ["playerctl", "--player=" + root.playerName, "shuffle", "Toggle"]; running: false
              onRunningChanged: if (!running) metaProc.running = true }
    Process { id: prevP;    command: ["playerctl", "--player=" + root.playerName, "previous"]; running: false
              onRunningChanged: if (!running) metaProc.running = true }
    Process { id: playP;    command: ["playerctl", "--player=" + root.playerName, "play-pause"]; running: false
              onRunningChanged: if (!running) metaProc.running = true }
    Process { id: nextP;    command: ["playerctl", "--player=" + root.playerName, "next"]; running: false
              onRunningChanged: if (!running) metaProc.running = true }
    Process { id: stopP;    command: ["playerctl", "--player=" + root.playerName, "stop"]; running: false
              onRunningChanged: if (!running) metaProc.running = true }
    Process { id: seekP;    command: ["playerctl", "--player=" + root.playerName, "position", Math.round(root.seekTarget).toString()]; running: false
              onRunningChanged: if (!running) metaProc.running = true }

    function fmtTime(s) {
        s = Math.max(0, Math.floor(s))
        var h   = Math.floor(s / 3600)
        var m   = Math.floor((s % 3600) / 60)
        var sec = s % 60
        var ss  = (sec < 10 ? "0" : "") + sec
        if (h > 0) return h + ":" + (m < 10 ? "0" : "") + m + ":" + ss
        return m + ":" + ss
    }

    function playerLabel() {
        var n = root.playerName
        var dot = n.indexOf(".")
        if (dot > 0) n = n.substring(0, dot)
        if (n.length === 0) return "Media"
        return n.charAt(0).toUpperCase() + n.slice(1)
    }

    function playerIcon() {
        var n = root.playerName.toLowerCase()
        if (n.indexOf("firefox") >= 0) return "\uf269"
        if (n.indexOf("spotify") >= 0) return "\uf1bc"
        if (n.indexOf("chrom") >= 0) return "\uf268"
        if (n.indexOf("vlc") >= 0) return "\udb80\udfd5"
        if (n.indexOf("mpv") >= 0) return "\uf04b"
        return "\uf001"
    }

    function seekTo(norm) {
        if (root.length <= 0) return
        norm = Math.max(0.0, Math.min(1.0, norm))
        root.seekTarget = Math.round(norm * root.length)
        root.position = root.seekTarget
        root.seekPending = true
        seekHoldTimer.restart()
        seekP.running = true
    }

    Item {
        id: card
        anchors.fill: parent
        readonly property int cornerRadius: 13

        layer.enabled: true
        layer.smooth: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: cardMask
        }

        Rectangle {
            anchors.fill: parent
            radius: card.cornerRadius
            color: "#15192a"
        }

        Image {
            id: cover
            anchors.fill: parent
            source: root.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            opacity: status === Image.Ready ? 0.72 : 0.0
            Behavior on opacity { NumberAnimation { duration: 220 } }
        }

        Rectangle {
            anchors.fill: parent
            color: cover.status === Image.Ready ? "#101522" : "#1a1c32"
            opacity: cover.status === Image.Ready ? 0.72 : 1.0
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.00; color: "#22324755" }
                GradientStop { position: 0.55; color: "#15192acc" }
                GradientStop { position: 1.00; color: "#101320f2" }
            }
        }

        Text {
            visible: cover.status !== Image.Ready
            anchors.centerIn: parent
            text: "\uf001"
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 64
            font.weight: Font.ExtraBold
            color: "#7cafff"
            opacity: 0.12
        }

        RowLayout {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 14
                leftMargin: 16
                rightMargin: 14
            }
            spacing: 10

            EqualizerGlyph {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                playing: root.isPlaying
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 15
                    font.weight: Font.ExtraBold
                    color: "#e7efff"
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    Layout.fillWidth: true
                    text: root.artist !== "" ? root.artist : root.playerLabel()
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#b7c9e9"
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    opacity: 0.82
                }
            }

            RowLayout {
                spacing: 8

                Text {
                    text: root.playerIcon()
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 16
                    font.weight: Font.ExtraBold
                    color: "#7cafff"
                }
            }
        }

        Item {
            id: progressArea
            anchors {
                left: parent.left
                right: parent.right
                bottom: controls.top
                leftMargin: 18
                rightMargin: 18
                bottomMargin: -10
            }
            height: 48

            property bool dragging: false
            property real dragValue: root.progress
            readonly property real visualValue: dragging
                ? dragValue
                : root.hasDuration ? root.progress : 1.0

            function setFromX(x) {
                if (!root.hasDuration) return
                dragValue = Math.max(0.0, Math.min(1.0, x / Math.max(1, progressTrack.width)))
            }

            Item {
                anchors {
                    left: progressTrack.left
                    right: progressTrack.right
                    bottom: progressTrack.top
                    bottomMargin: -2
                }
                height: 34
                clip: true

                ShaderEffect {
                    id: progressWave
                    anchors.bottom: parent.bottom
                    width: Math.max(1, progressTrack.width * progressArea.visualValue)
                    height: parent.height
                    visible: root.hasTimeline && width > 8

                    property real time: 0.0
                    property real timex2: 0.0
                    property real sizeW: width
                    property real maxSizeW: progressTrack.width
                    property real isPlaying: root.isPlaying && progressArea.visualValue >= 0.05 ? 1.0 : 0.0
                    property real excludedRadius: progressTrack.radius

                    Behavior on width {
                        enabled: !progressArea.dragging
                        NumberAnimation {
                            duration: 650
                            easing.bezierCurve: [0.42, 1.0, 0.21, 0.9, 1.0, 1.0]
                        }
                    }

                    Behavior on isPlaying { NumberAnimation { duration: 900 } }

                    NumberAnimation on time {
                        running: progressWave.isPlaying > 0.01
                        from: 0.0
                        to: Math.PI * 2.0
                        duration: 4000
                        loops: Animation.Infinite
                    }

                    NumberAnimation on timex2 {
                        running: progressWave.isPlaying > 0.01
                        from: 0.0
                        to: Math.PI * 2.0
                        duration: 2100
                        loops: Animation.Infinite
                    }

                    fragmentShader: Qt.resolvedUrl("../shaders/media-progress-wave.frag.qsb")
                }
            }

            Rectangle {
                id: progressTrack
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 22
                }
                height: 7
                radius: 4
                color: "#888c96a8"
                clip: true

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: root.hasTimeline ? Math.max(parent.height, parent.width * progressArea.visualValue) : 0
                    radius: parent.radius
                    color: "#7cafff"

                    Behavior on width {
                        enabled: !progressArea.dragging
                        NumberAnimation {
                            duration: 650
                            easing.bezierCurve: [0.42, 1.0, 0.21, 0.9, 1.0, 1.0]
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 180 } }
                }
            }

            Rectangle {
                id: progressThumb
                visible: root.hasDuration
                width: 14
                height: 14
                radius: 7
                x: progressTrack.x + progressTrack.width * progressArea.visualValue - width / 2
                y: progressTrack.y + (progressTrack.height - height) / 2
                color: root.isPlaying ? "#7cafff" : "#7cafff"
                border.width: 2
                border.color: "#7cafff"
                z: 3

                Behavior on x {
                    enabled: !progressArea.dragging
                    NumberAnimation {
                        duration: 650
                        easing.bezierCurve: [0.42, 1.0, 0.21, 0.9, 1.0, 1.0]
                    }
                }
                Behavior on color { ColorAnimation { duration: 180 } }
            }

            Text {
                visible: root.hasDuration || root.position > 0
                anchors {
                    left: progressTrack.left
                    top: progressTrack.bottom
                    topMargin: 6
                }
                text: root.fmtTime(root.hasDuration ? progressArea.visualValue * root.length : root.position)
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 10
                font.weight: Font.ExtraBold
                color: "#c9d7ef"
                opacity: 0.68
            }

            Text {
                visible: root.hasDuration
                anchors {
                    right: progressTrack.right
                    top: progressTrack.bottom
                    topMargin: 6
                }
                text: root.fmtTime(root.length)
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 10
                font.weight: Font.ExtraBold
                color: "#c9d7ef"
                opacity: 0.68
            }

            MouseArea {
                anchors {
                    left: progressTrack.left
                    right: progressTrack.right
                    top: progressTrack.top
                    bottom: parent.bottom
                    topMargin: -16
                }
                enabled: root.hasDuration
                cursorShape: Qt.PointingHandCursor
                onPressed: function(mouse) {
                    progressArea.dragging = true
                    progressArea.setFromX(mouse.x)
                }
                onPositionChanged: function(mouse) {
                    if (pressed)
                        progressArea.setFromX(mouse.x)
                }
                onReleased: {
                    root.seekTo(progressArea.dragValue)
                    progressArea.dragging = false
                }
                onCanceled: progressArea.dragging = false
            }
        }

        RowLayout {
            id: controls
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 13
            }
            spacing: 15

            MBtn { icon: "\uf074"; muted: true; onClicked: shuffleP.running = true }
            MBtn { icon: "\uf049"; onClicked: prevP.running = true }
            MBtn {
                icon: root.isPlaying ? "\uf04c" : "\uf04b"
                main: true
                sz: root.isPlaying ? 16 : 18
                onClicked: playP.running = true
            }
            MBtn { icon: "\uf050"; onClicked: nextP.running = true }
            MBtn { icon: "\uf04d"; danger: true; onClicked: stopP.running = true }
        }
    }

    Rectangle {
        id: cardMask
        anchors.fill: card
        radius: card.cornerRadius
        visible: false
        layer.enabled: true
    }

    component EqualizerGlyph: Item {
        id: glyph
        property bool playing: false

        Row {
            anchors.centerIn: parent
            height: 18
            spacing: 3

            EqBar { baseHeight: 10; lowHeight: 6;  highHeight: 17; durationA: 260; durationB: 320; playing: glyph.playing }
            EqBar { baseHeight: 15; lowHeight: 8;  highHeight: 16; durationA: 330; durationB: 380; playing: glyph.playing }
            EqBar { baseHeight: 8;  lowHeight: 10; highHeight: 15; durationA: 400; durationB: 440; playing: glyph.playing }
            EqBar { baseHeight: 13; lowHeight: 12; highHeight: 14; durationA: 470; durationB: 500; playing: glyph.playing }
        }

    }

    component EqBar: Rectangle {
        id: eqBar
        property int  baseHeight: 10
        property int  lowHeight:  6
        property int  highHeight: 17
        property int  durationA:  260
        property int  durationB:  320
        property bool playing:    false

        width: 3
        height: baseHeight
        y: parent ? (parent.height - height) / 2 : 0
        radius: 2
        color: "#dce7ff"
        opacity: playing ? 0.82 : 0.45

        SequentialAnimation on height {
            running: eqBar.playing
            loops: Animation.Infinite
            NumberAnimation { to: eqBar.lowHeight;  duration: eqBar.durationA; easing.type: Easing.InOutSine }
            NumberAnimation { to: eqBar.highHeight; duration: eqBar.durationB; easing.type: Easing.InOutSine }
        }
    }

    component MBtn: Item {
        id: btn
        property string icon: "\uf04b"
        property int    sz: 14
        property bool   main: false
        property bool   muted: false
        property bool   danger: false
        implicitWidth:  main ? 38 : 32
        implicitHeight: main ? 38 : 32
        signal clicked()

        property bool hov: hover.containsMouse

        Rectangle {
            anchors.fill: parent
            radius: btn.main ? 8 : 7
            color: "#ffffff"
            opacity: 0.0
        }

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: btn.sz
            font.weight: Font.ExtraBold
            color: btn.danger && btn.hov ? "#ff6b6b"
                 : btn.muted ? "#c3d3ec"
                 : "#dce8ff"
            opacity: btn.muted ? 0.72 : 1.0
            scale: btn.hov ? (btn.main ? 1.26 : 1.32) : 1.0
            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
        }

        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }
}
