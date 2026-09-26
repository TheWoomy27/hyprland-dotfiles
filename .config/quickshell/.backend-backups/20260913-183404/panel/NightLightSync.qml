import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool active: false
    property bool busy: setState.running
    property string controller: "/home/austin/.local/bin/hyprsunset-sync"

    function refresh() {
        if (!readState.running)
            readState.running = true
    }

    function toggle() {
        if (setState.running)
            return

        const nextState = !root.active
        root.active = nextState
        setState.command = [root.controller, "--set", nextState ? "on" : "off"]
        setState.running = true
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
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
