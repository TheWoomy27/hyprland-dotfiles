pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpuPercent: 0
    property real ramPercent: 0
    property real cpuTempC: 0
    property real totalMemoryKiB: 0

    function parseMeminfo(text) {
        const match = text.match(/^MemTotal:\s+(\d+)\s+kB$/m)
        if (match)
            totalMemoryKiB = Number(match[1])
    }

    function parseVmstat(line) {
        const fields = line.trim().split(/\s+/)
        if (fields.length < 17 || !/^\d+$/.test(fields[0]))
            return

        const free = Number(fields[3])
        const buffers = Number(fields[4])
        const cache = Number(fields[5])
        const idle = Number(fields[14])

        cpuPercent = Math.max(0, Math.min(100, 100 - idle))
        if (totalMemoryKiB > 0) {
            ramPercent = Math.max(0, Math.min(100,
                100 * (totalMemoryKiB - free - buffers - cache) / totalMemoryKiB))
        }
    }

    FileView {
        path: "/proc/meminfo"
        preload: true
        printErrors: false
        onLoaded: root.parseMeminfo(text())
    }

    Process {
        command: ["vmstat", "-w", "-n", "2"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => root.parseVmstat(line)
        }
    }

    Process {
        id: temperatureReader
        command: ["bash", "-c", "for d in /sys/class/hwmon/hwmon*; do [ -r \"$d/name\" ] || continue; [ \"$(cat \"$d/name\")\" = coretemp ] || continue; for label in \"$d\"/temp*_label; do [ -r \"$label\" ] || continue; if [ \"$(cat \"$label\")\" = \"Package id 0\" ]; then input=${label%_label}_input; [ -r \"$input\" ] && cat \"$input\" && exit 0; fi; done; [ -r \"$d/temp1_input\" ] && cat \"$d/temp1_input\" && exit 0; done; cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -1"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                const value = Number(line.trim())
                if (Number.isFinite(value))
                    root.cpuTempC = value / 1000
            }
        }
    }

    Timer {
        interval: 10000
        repeat: true
        triggeredOnStart: true
        running: true
        onTriggered: if (!temperatureReader.running) temperatureReader.running = true
    }
}
