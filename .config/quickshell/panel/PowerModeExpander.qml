// panel/PowerModeExpander.qml — header only, 48px fixed height
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    Layout.minimumWidth: 140
    implicitHeight: 48

    property string activeProfile: "balanced"
    property bool   expanded:      false

    readonly property var profiles: [
        { id: "performance", label: "Performance", icon: "\uf0e7" },
        { id: "balanced",    label: "Balanced",    icon: "\uf201" },
        { id: "power-saver", label: "Power Saver", icon: "\uf06c" }
    ]

    function iconFor(p) {
        for (var i = 0; i < profiles.length; i++)
            if (profiles[i].id === p) return profiles[i].icon
        return "\uf201"
    }

    Process {
        id: profileRead; command: ["powerprofilesctl", "get"]; running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(l) { root.activeProfile = l.trim() }
        }
    }

    property string _pendingProfile: ""

    Process {
        id: setProc
        command: ["powerprofilesctl", "set", root._pendingProfile]
        running: false
        onRunningChanged: if (!running && root._pendingProfile !== "") profileRead.running = true
    }

    function setProfile(id) {
        root._pendingProfile = id
        setProc.running = true
        root.expanded = false
    }

    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: profileRead.running = true }

    ExpandableToggle {
        anchors.fill: parent
        icon:     root.iconFor(root.activeProfile)
        label:    "Power Mode"
        active:   root.activeProfile === "performance"
        expanded: root.expanded
        onToggled:       root.expanded = !root.expanded
        onExpandClicked: root.expanded = !root.expanded
    }
}
