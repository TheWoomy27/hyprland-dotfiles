pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool blurEnabled: true
    property bool animationsEnabled: true
    property bool blurKnown: false
    property bool animationsKnown: false
    property string lastError: ""

    readonly property bool stateKnown: blurKnown && animationsKnown
    readonly property bool busy: toggleProcess.running
    readonly property bool reading: blurRead.running || animationsRead.running

    function refresh() {
        if (!blurRead.running)
            blurRead.running = true
        if (!animationsRead.running)
            animationsRead.running = true
    }

    function applyOption(line, option) {
        try {
            var value = JSON.parse(line)
            if (option === "blur") {
                blurEnabled = value.bool === true
                blurKnown = true
            } else {
                animationsEnabled = value.bool === true
                animationsKnown = true
            }
            lastError = ""
        } catch (_) {
            lastError = "Could not read compositor state."
        }
    }

    function toggleBlur() {
        if (busy)
            return
        if (!blurKnown) {
            refresh()
            return
        }

        toggleProcess.targetOption = "blur"
        toggleProcess.desiredValue = !blurEnabled
        toggleProcess.command = [
            "hyprctl",
            "eval",
            "hl.config({ decoration = { blur = { enabled = "
                + (toggleProcess.desiredValue ? "true" : "false") + " } } })"
        ]
        toggleProcess.running = true
    }

    function toggleAnimations() {
        if (busy)
            return
        if (!animationsKnown) {
            refresh()
            return
        }

        toggleProcess.targetOption = "animations"
        toggleProcess.desiredValue = !animationsEnabled
        toggleProcess.command = [
            "hyprctl",
            "eval",
            "hl.config({ animations = { enabled = "
                + (toggleProcess.desiredValue ? "true" : "false") + " } })"
        ]
        toggleProcess.running = true
    }

    Process {
        id: blurRead
        command: ["hyprctl", "getoption", "decoration:blur:enabled", "-j"]
        running: false
        stdout: StdioCollector { id: blurOutput }
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0)
                root.applyOption(blurOutput.text, "blur")
            else
                root.lastError = "Could not read blur state."
        }
    }

    Process {
        id: animationsRead
        command: ["hyprctl", "getoption", "animations:enabled", "-j"]
        running: false
        stdout: StdioCollector { id: animationsOutput }
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0)
                root.applyOption(animationsOutput.text, "animations")
            else
                root.lastError = "Could not read animation state."
        }
    }

    Process {
        id: toggleProcess
        property string targetOption: ""
        property bool desiredValue: false
        running: false
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                if (targetOption === "blur")
                    root.blurEnabled = desiredValue
                else if (targetOption === "animations")
                    root.animationsEnabled = desiredValue
                root.lastError = ""
            } else {
                root.lastError = "Could not update compositor state."
            }
            root.refresh()
        }
    }
}
