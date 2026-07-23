// modules/JarvisStatus.qml
// Left click: dashboard
// Right click: mute/wake
// Middle click: sleep
import QtQuick
import Quickshell
import Quickshell.Io

BarItem {
    id: root

    implicitWidth: 146
    hoverable: true
    bgColor: "#0b1424"
    shadowEnabled: effectivePresence === "speaking" || effectivePresence === "thinking"
    shadowColor: stateColor
    shadowOpacity: 0.35
    shadowBlur: 0.72
    shadowScale: 1.03
    shadowRingOpacity: 0.65
    shadowRingWidth: 4

    property string homeDir: Quickshell.env("HOME")
    property string statusPath: homeDir + "/.cache/jarvis-mark-ii/status.json"
    property string projectDir: homeDir + "/Projects/Jarvis/Mark-II"

    property string rawPresence: "offline"
    property string reason: "Runtime unavailable."
    property string updatedAt: ""
    property var context: ({})
    property var services: ({})
    property var perception: ({})
    property bool listening: false
    property bool speaking: false
    property bool streamStale: false
    property real clockMs: 0
    property real wakeUntilMs: 0
    readonly property bool wakeActive: listening || clockMs < wakeUntilMs
    property var activeJobs: ({})
    property int activeJobCount: 0
    property string activeJobLabel: ""
    property string lastAction: ""
    property bool actionPulse: false

    readonly property bool stale: {
        var stamp = Date.parse(updatedAt)
        return streamStale || isNaN(stamp) || clockMs - stamp > 15000
    }
    readonly property string effectivePresence: stale ? "offline" : rawPresence
    readonly property bool activeish: effectivePresence === "active"
                                    || effectivePresence === "speaking"
                                    || effectivePresence === "thinking"
    readonly property color stateColor: {
        if (activeJobCount > 0 && effectivePresence !== "speaking") return "#f8c46a"
        if (effectivePresence === "active") return "#7cafff"
        if (effectivePresence === "speaking") return "#82f7bd"
        if (effectivePresence === "thinking") return "#f8c46a"
        if (effectivePresence === "muted") return "#ff9d66"
        if (effectivePresence === "asleep") return "#76819a"
        return "#65758d"
    }
    readonly property string stateLabel: {
        if (effectivePresence === "asleep") return "SLEEP"
        if (wakeActive && !speaking) return "LISTENING"
        if (effectivePresence === "active" && listening) return "ACTIVE"
        return effectivePresence.toUpperCase()
    }
    readonly property string detailLabel: stale ? "OFFLINE"
                                               : (speaking ? "SPEAKING"
                                               : (wakeActive ? "LISTENING • SPEAK NOW"
                                               : (activeJobCount > 0 ? ("JOB • " + activeJobLabel)
                                               : (context.call_active ? "MUTED • CALL"
                                               : (context.gaming ? "MUTED • GAME"
                                               : (context.locked ? "SLEEP • LOCK"
                                               : (effectivePresence === "active" ? "ACTIVE • VOICE"
                                               : stateLabel)))))))
    readonly property bool ambientEnabled: perception.ambient_enabled === true
    readonly property string screenMode: perception.screen_mode || "off"

    signal toggleDashboard()

    function applyStatus(status) {
        rawPresence = status.presence || "offline"
        reason = status.reason || "Runtime unavailable."
        updatedAt = status.updated_at || ""
        context = status.context || ({})
        services = status.services || ({})
        perception = status.perception || ({})
        listening = status.listening === true
        speaking = status.speaking === true
        clockMs = Date.now()
    }

    function eventStamp(event) {
        if (event && event.ts)
            return new Date(event.ts * 1000).toISOString()
        return new Date().toISOString()
    }

    function derivedPresence() {
        if (speaking)
            return "speaking"
        if (context.locked)
            return "asleep"
        if (context.call_active || context.gaming)
            return "muted"
        return "active"
    }

    function markOffline() {
        rawPresence = "offline"
        reason = "Runtime unavailable."
        updatedAt = ""
        context = ({})
        services = ({})
        perception = ({})
        listening = false
        speaking = false
        clockMs = Date.now()
    }

    function serviceState(service) {
        return services[service] || "down"
    }

    function serviceColor(service) {
        var state = serviceState(service)
        if (state === "ok") return "#82f7bd"
        if (state === "stale") return "#f8c46a"
        return "#ff7a7a"
    }

    function applyHealthEvent(data) {
        if (!data || !data.service)
            return
        var service = String(data.service).toLowerCase()
        if (service !== "voice" && service !== "core" && service !== "agents" && service !== "perception")
            return
        var next = {}
        var keys = Object.keys(services)
        for (var i = 0; i < keys.length; i++)
            next[keys[i]] = services[keys[i]]
        next[service] = data.ok === true ? "ok" : "down"
        services = next
    }

    function privacyColor(kind) {
        if (stale || serviceState("perception") === "down") return "#ff7a7a"
        if (serviceState("perception") === "stale") return "#f8c46a"
        if (kind === "ears") return ambientEnabled ? "#82f7bd" : "#46556a"
        return screenMode !== "off" ? "#7cafff" : "#46556a"
    }

    function refreshActiveJobs() {
        var active = []
        var keys = Object.keys(activeJobs)
        for (var i = 0; i < keys.length; i++) {
            var job = activeJobs[keys[i]]
            if (job.status === "running" || job.status === "queued")
                active.push(job)
        }
        activeJobCount = active.length
        if (active.length > 0) {
            var job = active[0]
            activeJobLabel = ((job.adapter || "JOB") + " " + (job.status || "ACTIVE")).toUpperCase()
        } else {
            activeJobLabel = ""
        }
    }

    function applyAgentEvent(type, data) {
        if (!data || !data.job_id)
            return
        var jobs = {}
        var keys = Object.keys(activeJobs)
        for (var i = 0; i < keys.length; i++)
            jobs[keys[i]] = activeJobs[keys[i]]
        if (type === "agent.job.completed" || type === "agent.job.failed"
                || data.status === "succeeded" || data.status === "failed" || data.status === "blocked") {
            delete jobs[data.job_id]
        } else {
            jobs[data.job_id] = data
        }
        activeJobs = jobs
        refreshActiveJobs()
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
                root.rawPresence = data.presence || root.derivedPresence()
                root.reason = "Runtime telemetry live."
                root.updatedAt = root.eventStamp(event)
            } else if (event.type === "voice.wake") {
                // Instant "he heard me" — hold the listening state ~6s or until a turn ends.
                root.wakeUntilMs = Date.now() + 6000
                root.updatedAt = root.eventStamp(event)
            } else if (event.type === "speech.playback.started") {
                root.speaking = true
                root.wakeUntilMs = 0
                root.rawPresence = "speaking"
                root.updatedAt = root.eventStamp(event)
            } else if (event.type === "speech.playback.finished") {
                root.speaking = false
                root.rawPresence = root.derivedPresence()
                root.updatedAt = root.eventStamp(event)
            } else if (event.type.indexOf("agent.job.") === 0) {
                root.applyAgentEvent(event.type, data)
            } else if (event.type === "health.heartbeat") {
                root.applyHealthEvent(data)
            } else if (event.type === "ambient.state") {
                var ambient = {}
                var perceptionKeys = Object.keys(root.perception)
                for (var p = 0; p < perceptionKeys.length; p++)
                    ambient[perceptionKeys[p]] = root.perception[perceptionKeys[p]]
                ambient.ambient_enabled = data.enabled === true
                ambient.ambient_reason = data.reason || ""
                root.perception = ambient
            } else if (event.type === "screen.mode") {
                var screen = {}
                var screenKeys = Object.keys(root.perception)
                for (var s = 0; s < screenKeys.length; s++)
                    screen[screenKeys[s]] = root.perception[screenKeys[s]]
                screen.screen_mode = data.mode || "off"
                root.perception = screen
            }
        } catch (_) {
        }
    }

    function runControl(operation) {
        if (operation !== "wake" && operation !== "mute" && operation !== "sleep")
            return
        if (controlProc.running)
            return
        lastAction = operation.toUpperCase()
        actionPulse = true
        pulseTimer.restart()
        controlProc.operation = operation
        controlProc.command = [
            "bash",
            "-c",
            "cd " + root.projectDir + " && ./.venv/bin/jarvis control " + operation + " >/tmp/jarvis-quickshell-control.log 2>&1"
        ]
        controlProc.running = true
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
            property string reason: "Runtime unavailable."
            property string updated_at: ""
            property var context: ({})
            property var services: ({})
            property var perception: ({})
            property bool listening: false
            property bool speaking: false
        }

        function sync() {
            root.applyStatus({
                "presence": statusStore.presence,
                "reason": statusStore.reason,
                "updated_at": statusStore.updated_at,
                "context": statusStore.context,
                "services": statusStore.services,
                "perception": statusStore.perception,
                "listening": statusStore.listening,
                "speaking": statusStore.speaking
            })
        }

        onLoaded: sync()
        onAdapterUpdated: sync()
        onLoadFailed: {
            root.markOffline()
        }
    }

    Process {
        id: busStream
        command: [root.projectDir + "/.venv/bin/jarvis", "stream", "--filter", "context.,approval.,agent.,speech.,health.,ambient.,screen.,voice.wake"]
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
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.clockMs = Date.now()
    }

    Timer {
        id: pulseTimer
        interval: 650
        repeat: false
        onTriggered: root.actionPulse = false
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

    Process {
        id: controlProc
        running: false
        property string operation: ""
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onPressed: function(mouse) {
            mouse.accepted = true
            if (mouse.button === Qt.LeftButton) {
                root.lastAction = "DASH"
                root.actionPulse = true
                pulseTimer.restart()
                root.toggleDashboard()
            } else if (mouse.button === Qt.RightButton) {
                root.runControl(root.activeish ? "mute" : "wake")
            } else if (mouse.button === Qt.MiddleButton) {
                root.runControl(root.effectivePresence === "asleep" ? "wake" : "sleep")
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30

            // Seat: dark disc the orb sits in.
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#07111f"
                border.width: 1
                border.color: Qt.rgba(root.stateColor.r, root.stateColor.g, root.stateColor.b, root.wakeActive ? 0.95 : 0.55)
                opacity: 0.94
                Behavior on border.color { ColorAnimation { duration: 200 } }
            }

            // The living orb.
            JarvisOrb {
                anchors.fill: parent
                anchors.margins: 2
                accent: root.stateColor
                speaking: root.speaking
                listening: root.wakeActive && !root.speaking
                stale: root.stale
            }

            // Command-pulse echo on manual control.
            Rectangle {
                anchors.centerIn: parent
                width: root.actionPulse ? 32 : 18
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: root.stateColor
                opacity: root.actionPulse ? 0.7 : 0
                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 180 } }
            }

            // Job indicator dot (bottom-right), only when not busy speaking.
            Rectangle {
                anchors { right: parent.right; bottom: parent.bottom }
                width: 10
                height: 10
                radius: 5
                color: "#f8c46a"
                border.width: 1
                border.color: "#0b1424"
                visible: root.activeJobCount > 0 && !root.speaking
                SequentialAnimation on opacity {
                    running: parent.visible
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.35; duration: 700 }
                    NumberAnimation { to: 1.0; duration: 700 }
                }
            }

            Row {
                anchors {
                    top: parent.top
                    left: parent.left
                    topMargin: -1
                    leftMargin: -1
                }
                spacing: 2

                HealthDot { service: "voice" }
                HealthDot { service: "core" }
                HealthDot { service: "agents" }
                PrivacyDot { kind: "ears" }
                PrivacyDot { kind: "eyes" }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: "J.A.R.V.I.S."
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 10
                font.weight: Font.ExtraBold
                font.letterSpacing: 1.4
                color: root.stateColor
            }

            Text {
                width: 92
                text: root.actionPulse ? ("CMD " + root.lastAction) : root.detailLabel
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 8
                font.weight: Font.DemiBold
                color: "#9db1ca"
            }
        }
    }

    component HealthDot: Rectangle {
        required property string service

        width: 5
        height: 5
        radius: 3
        color: root.serviceColor(service)
        border.width: 1
        border.color: "#0b1424"
        opacity: root.stale ? 0.35 : 0.95
    }

    component PrivacyDot: Rectangle {
        required property string kind

        width: 5
        height: 5
        radius: 3
        color: root.privacyColor(kind)
        border.width: 1
        border.color: "#0b1424"
        opacity: root.stale ? 0.35 : 0.95
    }
}
