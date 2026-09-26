// panel/VolumeSlider.qml — event-driven PipeWire volume and output selection
import QtQuick
import QtQuick.Layouts
import "../services" as Backend

Item {
    id: root
    implicitWidth: parent ? parent.width : 300
    implicitHeight: col.implicitHeight

    readonly property real volume: Backend.AudioService.volume
    readonly property bool muted: Backend.AudioService.muted
    readonly property var sinks: Backend.AudioService.sinks
    property bool expanded: false

    property bool panelOpen: true
    onPanelOpenChanged: if (!panelOpen) root.expanded = false

    function volIcon() {
        if (muted || Math.round(volume * 100) === 0)
            return "\uf026";
        if (volume < 0.5)
            return "\uf027";
        return "\uf028";
    }

    Column {
        id: col
        width: parent.width
        spacing: 0

        RowLayout {
            width: parent.width
            spacing: 10

            Text {
                text: root.volIcon()
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 18
                font.weight: Font.ExtraBold
                color: root.muted ? "#6b7fa3" : "#7cafff"
                Behavior on color { ColorAnimation { duration: 120 } }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Backend.AudioService.toggleMute()
                }
            }

            PanelSlider {
                Layout.fillWidth: true
                value: Math.min(root.volume, 1.0)
                minValue: 0.0
                maxValue: 1.0
                onMoved: function(value) { Backend.AudioService.setVolume(value); }
            }

            Text {
                text: Math.round(root.volume * 100) + "%"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 12
                font.weight: Font.ExtraBold
                color: "#7cafff"
                Layout.minimumWidth: 36
            }

            Item {
                width: 24
                height: 24
                Text {
                    anchors.centerIn: parent
                    text: "\uf078"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 11
                    font.weight: Font.ExtraBold
                    color: "#7cafff"
                    rotation: root.expanded ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = !root.expanded
                }
            }
        }

        Item {
            width: parent.width
            height: root.expanded ? sinkBox.implicitHeight + 12 : 0
            clip: true
            Behavior on height { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

            Rectangle {
                id: sinkBox
                anchors { top: parent.top; topMargin: 8; left: parent.left; right: parent.right }
                implicitHeight: sinkList.implicitHeight + 8
                radius: 12
                color: "#1e2030"
                clip: true

                Column {
                    id: sinkList
                    anchors { fill: parent; topMargin: 4; bottomMargin: 4 }
                    spacing: 0

                    Repeater {
                        model: root.sinks
                        delegate: SinkRow {
                            required property var modelData
                            sink: modelData
                            width: sinkList.width
                        }
                    }
                }
            }
        }
    }

    component SinkRow: Item {
        required property var sink
        readonly property string sinkName: sink ? (sink.description || sink.nickname || sink.name) : "Unknown output"
        readonly property bool isActive: sink === Backend.AudioService.sink
        implicitHeight: 36
        property bool hov: sh.containsMouse

        Rectangle {
            anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
            radius: 8
            color: isActive ? "#2f334d" : "transparent"
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "#222436"
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
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: isActive ? "#7cafff" : "#b4c2f0"
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: sh
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (!isActive) Backend.AudioService.setDefaultSink(sink)
        }
    }
}
