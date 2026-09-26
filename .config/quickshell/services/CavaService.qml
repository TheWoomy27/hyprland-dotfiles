pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int barCount: 24
    readonly property int maxLevel: 7
    readonly property bool visualizerEnabled: Quickshell.env("MOONLIGHT_ENABLE_CAVA") === "1"
    readonly property bool mediaPlaying: MediaService.active
        ? MediaService.active.isPlaying
        : false
    property bool audioPlaying: false
    property bool shouldShow: false
    property var levels: Array(barCount).fill(0)

    onMediaPlayingChanged: {
        if (visualizerEnabled && mediaPlaying)
            return
        audioPlaying = false
        lingerTimer.restart()
    }

    onVisualizerEnabledChanged: {
        if (!visualizerEnabled) {
            audioPlaying = false
            shouldShow = false
        }
    }

    onAudioPlayingChanged: {
        if (audioPlaying) {
            lingerTimer.stop()
            shouldShow = true
        } else {
            lingerTimer.restart()
        }
    }

    Timer {
        id: lingerTimer
        interval: 5000
        onTriggered: root.shouldShow = false
    }

    Process {
        command: ["cava", "-p", `${Quickshell.env("HOME")}/.config/quickshell/cava-bar.ini`]
        running: root.visualizerEnabled && root.mediaPlaying
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                let text = line.trim()
                if (!text)
                    return
                if (text.endsWith(";"))
                    text = text.slice(0, -1)

                const parts = text.split(";")
                const next = []
                let hasSignal = false
                for (let index = 0; index < root.barCount; index++) {
                    const level = index < parts.length
                        ? Math.min(Number(parts[index]) || 0, root.maxLevel)
                        : 0
                    hasSignal = hasSignal || level > 0
                    next.push(level)
                }
                root.levels = next
                root.audioPlaying = hasSignal
            }
        }
    }
}
