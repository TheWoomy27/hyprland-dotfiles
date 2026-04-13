// panel/WifiExpander.qml — header only, state + signals exposed to ToggleGrid
import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitHeight: 48

    // State exposed to ToggleGrid for the dropdown
    property string ssid:     ""
    property var    networks: []
    property bool   expanded: false

    signal wifiToggleClicked()
    signal networkSelected(string ssid)

    Process {
        id: wifiStatus
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes' | head -1"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var p = line.trim().split(":")
                root.ssid = (p.length >= 2 && p[0] === "yes") ? p[1] : ""
            }
        }
    }

    Process {
        id: scanProc
        command: ["bash", "-c",
            "nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list 2>/dev/null | head -12"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var p = line.split(":")
                if (p.length >= 2 && p[0].trim()) {
                    root.networks = root.networks.concat([{
                        ssid:    p[0].trim(),
                        signal:  parseInt(p[1]) || 0,
                        secured: ((p[2]||"").includes("WPA") || (p[2]||"").includes("WEP")),
                        active:  (p[3]||"").trim() === "*"
                    }])
                }
            }
        }
    }

    Process {
        id: wifiToggle
        command: ["bash", "-c",
            "nmcli radio wifi $(nmcli radio wifi | grep -q enabled && echo off || echo on)"]
        running: false
        onRunningChanged: if (!running) wifiStatus.running = true
    }

    Timer { interval: 10000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: wifiStatus.running = true }

    // Public methods
    function toggleWifi()  { wifiToggle.running = true }
    function scan()        { root.networks = []; scanProc.running = true }

    ExpandableToggle {
        anchors.fill: parent
        icon:     "\uf1eb"
        label:    root.ssid !== "" ? root.ssid : "Wi-Fi"
        active:   root.ssid !== ""
        expanded: root.expanded
        onToggled:       root.toggleWifi()
        onExpandClicked: {
            root.expanded = !root.expanded
            if (root.expanded) root.scan()
        }
    }
}
