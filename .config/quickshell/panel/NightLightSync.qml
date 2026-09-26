import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool active: false
    property bool busy: setState.running
    property string controller: "/home/austin/.local/bin/hyprsunset-sync"
    property bool controllerAvailable: false
    property bool controllerChecked: false

    function refresh() {
        if (root.enabled && root.controllerAvailable && !readState.running)
            readState.running = true
    }

    function toggle() {
        if (!root.controllerAvailable || setState.running)
            return

        const nextState = !root.active
        root.active = nextState
        setState.command = [root.controller, "--set", nextState ? "on" : "off"]
        setState.running = true
    }

    function probeController() {
        if (root.enabled && !root.controllerChecked && !controllerProbe.running)
            controllerProbe.running = true
    }

    onEnabledChanged: probeController()
    Component.onCompleted: probeController()

    Process {
        id: controllerProbe
        command: ["test", "-x", root.controller]
        running: false
        onExited: function(exitCode, exitStatus) {
            root.controllerChecked = true
            root.controllerAvailable = exitCode === 0
            if (root.controllerAvailable)
                root.refresh()
        }
    }

    Process {
        id: readState
        command: [root.controller, "--status"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                const state = line.trim()
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
        onRunningChanged: {
            if (!running)
                root.refresh()
        }
    }

    Timer {
        interval: 3000
        running: root.enabled && root.controllerAvailable
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
