// panel/VolumeSlider.qml — sink list never auto-refreshes while open (prevents flicker)
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    implicitWidth:  parent ? parent.width : 300
    implicitHeight: col.implicitHeight

    property real   volume:      0.5
    property bool   muted:       false
    property var    sinks:       []
    property bool   expanded:    false
    property string _pendingPct: ""

    property bool panelOpen: true
    onPanelOpenChanged: { if (!panelOpen) root.expanded = false }

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
        id: volSet
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", root._pendingPct]
        running: false
        onRunningChanged: {
            if (!running && root._pendingPct !== "") {
                root._pendingPct = ""
                volRead.running = true
            }
        }
    }

    // Sink scan — only run on demand, never on a timer while expanded
    Process {
        id: sinksRead
        command: ["bash", "-c",
            "wpctl status 2>/dev/null | awk '/Sinks:/,/Sources:/' | grep -E '\\*|[0-9]+\\.' | head -10"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var m = line.match(/(\*?)\s*(\d+)\.\s+(.+?)\s+\[/)
                if (m) {
                    root.sinks = root.sinks.concat([{
                        id:     m[2],
                        name:   m[3].trim(),
                        active: m[1].trim() === "*"
                    }])
                }
            }
        }
    }

    Process { id: volMute; command: ["wpctl","set-mute","@DEFAULT_AUDIO_SINK@","toggle"]; running: false }

    Timer {
        id: refreshTimer; interval: 200
        onTriggered: volRead.running = true
    }

    // Volume-only timer — does NOT touch sink list
    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: volRead.running = true
    }

    function openSinks() { root.sinks = []; sinksRead.running = true }

    function volIcon() {
        if (muted || Math.round(volume * 100) === 0) return "\uf026"
        if (volume < 0.5) return "\uf027"
        return "\uf028"
    }

    Column {
        id: col
        width: parent.width
        spacing: 0

        RowLayout {
            width: parent.width; spacing: 10

            Text {
                text: root.volIcon()
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 18; font.weight: Font.ExtraBold
                color: root.muted ? "#6b7fa3" : "#7cafff"
                Behavior on color { ColorAnimation { duration: 120 } }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: { volMute.running = true; refreshTimer.restart() }
                }
            }

            PanelSlider {
                Layout.fillWidth: true
                value:    Math.min(root.volume, 1.0)
                minValue: 0.0; maxValue: 1.0
                onMoved: function(v) {
                    root.volume = v
                    root._pendingPct = Math.round(v * 100) + "%"
                    if (!volSet.running) volSet.running = true
                }
            }

            Text {
                text: Math.round(root.volume * 100) + "%"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 12; font.weight: Font.ExtraBold
                color: "#7cafff"; Layout.minimumWidth: 36
            }

            // Rotating chevron
            Item {
                width: 24; height: 24
                Text {
                    anchors.centerIn: parent; text: "\uf078"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 11; font.weight: Font.ExtraBold; color: "#7cafff"
                    rotation: root.expanded ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.expanded = !root.expanded
                        if (root.expanded) root.openSinks()
                    }
                }
            }
        }

        // Sink list expander
        Item {
            width:  parent.width
            height: root.expanded ? sinkBox.implicitHeight + 12 : 0
            clip:   true
            Behavior on height { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

            Rectangle {
                id: sinkBox
                anchors { top: parent.top; topMargin: 8; left: parent.left; right: parent.right }
                implicitHeight: sinkList.implicitHeight + 8
                radius: 12; color: "#1e2030"; clip: true

                Column {
                    id: sinkList
                    anchors { fill: parent; topMargin: 4; bottomMargin: 4 }
                    spacing: 0

                    Repeater {
                        model: root.sinks
                        delegate: SinkRow {
                            required property var modelData
                            sinkId:   modelData.id
                            sinkName: modelData.name
                            isActive: modelData.active
                            width:    sinkList.width
                            // On selection, re-scan ONCE to confirm new active
                            onSinkSelected: root.openSinks()
                        }
                    }
                }
            }
        }
    }

    component SinkRow: Item {
        property string sinkId:   ""
        property string sinkName: ""
        property bool   isActive: false
        signal sinkSelected()
        implicitHeight: 36
        property bool hov: sh.containsMouse

        Rectangle {
            anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
            radius: 8; color: isActive ? "#2f334d" : "transparent"
            Rectangle {
                anchors.fill: parent; radius: parent.radius; color: "#222436"
                opacity: (hov && !isActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
            Row {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                spacing: 8
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: isActive ? "\uf058" : "\uf111"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 11
                    color: isActive ? "#7cafff" : "#36394c"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: sinkName
                    width: parent.width - 36
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 12; font.weight: Font.Bold
                    color: isActive ? "#7cafff" : "#b4c2f0"; elide: Text.ElideRight
                }
            }
        }

        Process {
            id: setSink; command: ["wpctl","set-default",sinkId]; running: false
            onRunningChanged: if (!running) parent.sinkSelected()
        }

        MouseArea {
            id: sh; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (!isActive) setSink.running = true
        }
    }
}
