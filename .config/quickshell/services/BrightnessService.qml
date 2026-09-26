pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string deviceName: ""
    property int maximum: 100
    property int percent: 50
    property int desiredPercent: 50
    property int launchedPercent: -1
    readonly property bool available: deviceName !== ""

    function applyRaw(value) {
        var current = Number(String(value).trim());
        if (!Number.isFinite(current) || maximum <= 0)
            return;
        percent = Math.max(0, Math.min(100, Math.round(current * 100 / maximum)));
        desiredPercent = percent;
    }

    function parseDiscovery(output) {
        var fields = output.trim().split(",");
        if (fields.length < 5 || fields[0] === "")
            return;

        deviceName = fields[0];
        maximum = Math.max(1, Number(fields[4]) || 100);
        var reportedPercent = Number(fields[3].replace("%", ""));
        if (Number.isFinite(reportedPercent)) {
            percent = Math.max(0, Math.min(100, Math.round(reportedPercent)));
            desiredPercent = percent;
        }
    }

    function setPercent(value) {
        if (!available)
            return;
        percent = Math.max(1, Math.min(100, Math.round(value)));
        desiredPercent = percent;
        commitTimer.restart();
    }

    Process {
        command: ["brightnessctl", "-m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.parseDiscovery(text)
        }
    }

    FileView {
        id: valueFile
        path: root.available ? "/sys/class/backlight/" + root.deviceName + "/brightness" : "/dev/null"
        preload: root.available
        watchChanges: root.available
        printErrors: false
        onLoaded: root.applyRaw(text())
        onTextChanged: root.applyRaw(text())
        onFileChanged: reload()
    }

    Timer {
        id: commitTimer
        interval: 45
        onTriggered: {
            if (setProcess.running) {
                restart();
                return;
            }
            root.launchedPercent = root.desiredPercent;
            setProcess.command = ["brightnessctl", "-d", root.deviceName,
                "set", root.launchedPercent + "%"];
            setProcess.running = true;
        }
    }

    Process {
        id: setProcess
        running: false
        onRunningChanged: {
            if (running || root.launchedPercent < 0)
                return;
            if (root.desiredPercent !== root.launchedPercent)
                commitTimer.restart();
            else
                valueFile.reload();
        }
    }
}
