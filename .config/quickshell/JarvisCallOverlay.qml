// JarvisCallOverlay.qml
import Quickshell
import Quickshell.Io
import QtQuick

PanelWindow {
    id: root

    required property var screen

    screen: root.screen
    // Mode detection still runs; this only disables the bottom-right notification card.
    property bool modeNotificationsEnabled: false
    visible: modeNotificationsEnabled && quietActive
    anchors { right: true; bottom: true }
    margins { right: 28; bottom: 36 }
    implicitWidth: 356
    implicitHeight: 112
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    property string homeDir: Quickshell.env("HOME")
    property string statusPath: homeDir + "/.cache/jarvis-mark-ii/status.json"
    property string projectDir: homeDir + "/Projects/Jarvis/Mark-II"
    property string rawPresence: "offline"
    property string reason: ""
    property string updatedAt: ""
    property var context: ({})
    property bool streamStale: false
    property real clockMs: 0

    readonly property bool stale: {
        var stamp = Date.parse(updatedAt)
        return streamStale || isNaN(stamp) || clockMs - stamp > 15000
    }
    readonly property bool quietActive: !stale && (context.call_active === true || context.gaming === true)
    readonly property color accent: context.call_active ? "#49dff9" : "#f8c46a"
    readonly property string title: context.call_active ? "COMMUNICATION CHANNEL ACTIVE" : "GAME MODE DETECTED"
    readonly property string detail: context.call_active
                                     ? "Voice output muted until the call concludes."
                                     : "Jarvis is quiet while the game is active."

    function syncStatus() {
        rawPresence = statusStore.presence || "offline"
        reason = statusStore.reason || ""
        updatedAt = statusStore.updated_at || ""
        context = statusStore.context || ({})
        clockMs = Date.now()
    }

    function eventStamp(event) {
        if (event && event.ts)
            return new Date(event.ts * 1000).toISOString()
        return new Date().toISOString()
    }

    function applyBusEvent(line) {
        if (!line || !line.length)
            return
        try {
            var event = JSON.parse(line)
            var data = event.data || {}
            root.streamStale = false
            root.clockMs = Date.now()
            if (event.type === "context.changed") {
                root.context = {
                    "locked": data.locked === true,
                    "call_active": data.call_active === true,
                    "gaming": data.gaming === true,
                    "active_window": data.active_window || "",
                    "active_class": data.active_class || ""
                }
                root.rawPresence = data.presence || "active"
                root.reason = "Runtime telemetry live."
                root.updatedAt = root.eventStamp(event)
            } else if (event.type === "speech.playback.started") {
                root.rawPresence = "speaking"
                root.updatedAt = root.eventStamp(event)
            } else if (event.type === "speech.playback.finished") {
                root.rawPresence = data.presence || "active"
                root.updatedAt = root.eventStamp(event)
            }
        } catch (_) {
        }
    }

    FileView {
        id: statusFile
        path: root.statusPath
        preload: true
        blockLoading: true
        watchChanges: true
        printErrors: false

        JsonAdapter {
            id: statusStore
            property string presence: "offline"
            property string reason: ""
            property string updated_at: ""
            property var context: ({})
        }

        onLoaded: root.syncStatus()
        onAdapterUpdated: root.syncStatus()
        onLoadFailed: {
            root.rawPresence = "offline"
            root.reason = ""
            root.updatedAt = ""
            root.context = ({})
            root.clockMs = Date.now()
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.clockMs = Date.now()
    }

    Process {
        id: busStream
        command: [root.projectDir + "/.venv/bin/jarvis", "stream", "--filter", "context.,approval.,agent.,speech.,health."]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) { root.applyBusEvent(line) }
        }
        onRunningChanged: {
            if (running) {
                root.streamStale = false
                return
            }
            root.streamStale = true
            streamRestartTimer.restart()
        }
    }

    Timer {
        id: streamRestartTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (!busStream.running)
                busStream.running = true
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: "#0b1524"
        border.width: 1
        border.color: root.accent
        opacity: 0.97
    }

    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 11 }
        width: 3
        radius: 2
        color: root.accent
        SequentialAnimation on opacity {
            running: root.quietActive
            loops: Animation.Infinite
            NumberAnimation { to: 0.25; duration: 650 }
            NumberAnimation { to: 1.0; duration: 650 }
        }
    }

    Column {
        anchors { fill: parent; leftMargin: 30; rightMargin: 18; topMargin: 17; bottomMargin: 14 }
        spacing: 7

        Text {
            text: root.title
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 10
            font.weight: Font.ExtraBold
            font.letterSpacing: 0.8
            color: root.accent
        }

        Text {
            text: root.context.call_active ? "Call quiet mode" : "Gaming quiet mode"
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 17
            font.weight: Font.DemiBold
            color: "#e2f7fb"
        }

        Text {
            text: root.detail
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 11
            color: "#93b8c2"
        }
    }
}
