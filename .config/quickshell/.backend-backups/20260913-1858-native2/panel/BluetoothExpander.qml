// panel/BluetoothExpander.qml — header only
import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitHeight: 48

    property bool   btOn:     false
    property var    devices:  []
    property bool   expanded: false

    Process {
        id: btStatus
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep -i 'powered:' | awk '{print $2}'"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(l) { root.btOn = l.trim().toLowerCase() === "yes" }
        }
    }

    Process {
        id: devScan
        command: ["bash", "-c",
            "bluetoothctl devices Connected 2>/dev/null | while read _ mac name; do " +
            "  bat=$(bluetoothctl info \"$mac\" 2>/dev/null | grep 'Battery Percentage' | grep -oP '\\d+' | head -1); " +
            "  echo \"$mac|||$name|||${bat:-}\"; done"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var p = line.split("|||")
                if (p.length >= 2 && p[0].trim())
                    root.devices = root.devices.concat([{
                        mac: p[0].trim(), name: p[1].trim(), battery: p[2] ? p[2].trim() : ""
                    }])
            }
        }
    }

    Process {
        id: btToggle
        command: ["bash", "-c", "bluetoothctl power " + (root.btOn ? "off" : "on")]
        running: false
        onRunningChanged: if (!running) btStatus.running = true
    }

    Timer { interval: 8000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: btStatus.running = true }

    function scan() { root.devices = []; devScan.running = true }

    ExpandableToggle {
        anchors.fill: parent
        icon:     "\uf294"
        iconPixelSize: 21
        iconHoverScale: 1.28
        chevronHoverScale: 1.28
        label:    "Bluetooth"
        active:   root.btOn
        expanded: root.expanded
        onToggled:       btToggle.running = true
        onExpandClicked: {
            root.expanded = !root.expanded
            if (root.expanded) root.scan()
        }
    }
}
