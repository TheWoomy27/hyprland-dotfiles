pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string controller: Quickshell.env("HOME") + "/.local/bin/hyprsunset-sync"
    property bool available: false
    property bool checked: false
    property bool active: false
    property int monitorClients: 0

    readonly property bool busy: setState.running
    readonly property bool monitoring: available && monitorClients > 0

    function acquireMonitor() {
        monitorClients += 1
    }

    function releaseMonitor() {
        monitorClients = Math.max(0, monitorClients - 1)
    }

    function refresh() {
        if (available && !readState.running)
            readState.running = true
    }

    function toggle() {
        if (!available || setState.running)
            return

        var nextState = !active
        active = nextState
        setState.command = [controller, "--set", nextState ? "on" : "off"]
        setState.running = true
    }

    onMonitoringChanged: {
        if (monitoring)
            refresh()
    }

    Process {
        command: ["test", "-x", root.controller]
        running: true
        onExited: function(exitCode, exitStatus) {
            root.checked = true
            root.available = exitCode === 0
            if (!root.available)
                root.active = false
        }
    }

    Process {
        id: readState
        command: [root.controller, "--status"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                var state = line.trim()
                if (state === "on")
                    root.active = true
                else if (state === "off" || state === "unknown")
                    root.active = false
            }
        }
    }

    Process {
        id: setState
        running: false
        onExited: function(exitCode, exitStatus) {
            root.refresh()
        }
    }

    Timer {
        interval: 3000
        running: root.monitoring
        repeat: true
        onTriggered: root.refresh()
    }
}
