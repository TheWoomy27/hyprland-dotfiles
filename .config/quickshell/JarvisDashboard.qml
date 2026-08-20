// JarvisDashboard.qml
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var screen
    property bool open: false
    signal dismissRequested()

    visible: open
    screen: root.screen
    anchors { top: true; right: true; bottom: true }
    margins { top: 72; right: 20; bottom: 20 }
    implicitWidth: 430
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    property string homeDir: Quickshell.env("HOME")
    property string statusPath: homeDir + "/.cache/jarvis-mark-ii/status.json"
    property string projectDir: homeDir + "/Projects/Jarvis"

    property string rawPresence: "offline"
    property string reason: "Runtime unavailable."
    property string updatedAt: ""
    property string currentTask: ""
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
    property string activeJobLabel: "CLEAR"
    property string activeJobPrompt: ""
    property int mobileDeviceCount: 0
    property string mobileDeviceLabel: "UNPAIRED"
    property var pendingApprovals: []
    property var activityToday: []
    property int pendingMemories: 0
    property var memoryReview: ({})
    property var initiative: ({})
    property int watchingCount: 0
    property int queuedCount: 0

    readonly property bool stale: {
        var stamp = Date.parse(updatedAt)
        return streamStale || isNaN(stamp) || clockMs - stamp > 15000
    }
    readonly property string effectivePresence: stale ? "offline" : rawPresence
    readonly property color stateColor: {
        if (effectivePresence === "active") return "#7cafff"
        if (effectivePresence === "speaking") return "#82f7bd"
        if (effectivePresence === "thinking") return "#f8c46a"
        if (effectivePresence === "muted") return "#ff9d66"
        if (effectivePresence === "asleep") return "#76819a"
        return "#65758d"
    }
    readonly property string activeWindow: context.active_window || "No active window data."
    readonly property string activeClass: context.active_class || "unknown"
    readonly property string quietReason: context.call_active ? "Mobile or voice call detected."
                                       : (context.gaming ? "Game detected."
                                       : (context.locked ? "Hyprlock active." : "No quiet-mode trigger."))
    readonly property bool ambientEnabled: perception.ambient_enabled === true
    readonly property string screenMode: perception.screen_mode || "off"

    function syncStatus() {
        rawPresence = statusStore.presence || "offline"
        reason = statusStore.reason || "Runtime unavailable."
        updatedAt = statusStore.updated_at || ""
        currentTask = statusStore.current_task || ""
        context = statusStore.context || ({})
        services = statusStore.services || ({})
        perception = statusStore.perception || ({})
        listening = statusStore.listening === true
        speaking = statusStore.speaking === true
        pendingApprovals = statusStore.pending_approvals || []
        activityToday = statusStore.activity_today || []
        pendingMemories = statusStore.pending_memories || 0
        memoryReview = statusStore.memory_review || ({})
        initiative = statusStore.initiative || ({})
        watchingCount = initiative.watching || 0
        queuedCount = initiative.queued || 0
        clockMs = Date.now()
    }

    function activityTime(row) {
        if (!row || !row.span_end)
            return "--:--"
        var stamp = new Date(row.span_end * 1000)
        var hours = stamp.getHours() < 10 ? ("0" + stamp.getHours()) : String(stamp.getHours())
        var minutes = stamp.getMinutes() < 10 ? ("0" + stamp.getMinutes()) : String(stamp.getMinutes())
        return hours + ":" + minutes
    }

    function activityApps(row) {
        if (!row || !row.apps || row.apps.length === 0)
            return "unknown"
        return row.apps.slice(0, 2).join(", ")
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

    function runControl(operation) {
        if (operation !== "wake" && operation !== "mute" && operation !== "sleep")
            return
        if (controlProc.running)
            return
        controlProc.operation = operation
        controlProc.command = [
            "bash",
            "-lc",
            "cd " + root.projectDir + " && ./.venv/bin/jarvis control " + operation + " >/dev/null"
        ]
        controlProc.running = true
    }

    function resolveApproval(approvalId, approve) {
        if (!approvalId || approvalProc.running)
            return
        approvalProc.command = [
            "bash",
            "-lc",
            "cd " + root.projectDir + " && ./.venv/bin/jarvis " + (approve ? "approve " : "deny ") + approvalId + " >/dev/null"
        ]
        approvalProc.running = true
    }

    function resolveMemory(memoryId, confirm) {
        if (!memoryId || memoryProc.running)
            return
        memoryProc.command = [
            "bash",
            "-lc",
            "cd " + root.projectDir + " && ./.venv/bin/jarvis memories " + (confirm ? "confirm " : "reject ") + memoryId + " >/dev/null"
        ]
        memoryProc.running = true
    }

    function upsertApproval(data) {
        if (!data || !data.approval_id)
            return
        var approvals = []
        for (var i = 0; i < pendingApprovals.length; i++) {
            if (pendingApprovals[i].id !== data.approval_id)
                approvals.push(pendingApprovals[i])
        }
        approvals.unshift({
            "id": data.approval_id,
            "summary": data.summary || "Approval required.",
            "risk": data.risk || "unknown",
            "expires_at": data.expires_at || ""
        })
        pendingApprovals = approvals
    }

    function removeApproval(data) {
        if (!data || !data.approval_id)
            return
        var approvals = []
        for (var i = 0; i < pendingApprovals.length; i++) {
            if (pendingApprovals[i].id !== data.approval_id)
                approvals.push(pendingApprovals[i])
        }
        pendingApprovals = approvals
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

    function privacyLabel(kind) {
        if (kind === "ears") return ambientEnabled ? "ON" : "OFF"
        return screenMode.toUpperCase()
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
            activeJobLabel = ((job.adapter || "worker") + " • " + (job.status || "active")).toUpperCase()
            activeJobPrompt = job.prompt_summary || job.prompt || ""
        } else {
            activeJobLabel = "CLEAR"
            activeJobPrompt = ""
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
            } else if (event.type === "approval.requested") {
                root.upsertApproval(data)
            } else if (event.type === "approval.resolved") {
                root.removeApproval(data)
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
            property string current_task: ""
            property var context: ({})
            property var services: ({})
            property var perception: ({})
            property bool listening: false
            property bool speaking: false
            property var pending_approvals: []
            property var activity_today: []
            property int pending_memories: 0
            property var memory_review: ({})
            property var initiative: ({})
        }

        onLoaded: root.syncStatus()
        onAdapterUpdated: root.syncStatus()
        onLoadFailed: {
            root.rawPresence = "offline"
            root.reason = "Runtime unavailable."
            root.updatedAt = ""
            root.currentTask = ""
            root.context = ({})
            root.services = ({})
            root.perception = ({})
            root.listening = false
            root.speaking = false
            root.pendingApprovals = []
            root.activityToday = []
            root.pendingMemories = 0
            root.memoryReview = ({})
            root.initiative = ({})
            root.watchingCount = 0
            root.queuedCount = 0
            root.clockMs = Date.now()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.clockMs = Date.now()
    }

    Process {
        id: controlProc
        running: false
        property string operation: ""
    }

    Process {
        id: approvalProc
        running: false
    }

    Process {
        id: memoryProc
        running: false
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
        radius: 24
        color: "#08111f"
        border.width: 1
        border.color: Qt.rgba(root.stateColor.r, root.stateColor.g, root.stateColor.b, 0.78)
        opacity: 0.98
    }

    Rectangle {
        anchors { fill: parent; margins: 4 }
        radius: 20
        color: "#0d1728"
        border.width: 1
        border.color: "#173b54"
    }

    // The living orb, echoing the pill — calm at idle, attentive on wake, rippling on speech.
    JarvisOrb {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 18
            rightMargin: 20
        }
        width: 116
        height: 116
        opacity: 0.9
        accent: root.stateColor
        speaking: root.speaking
        listening: root.wakeActive && !root.speaking
        stale: root.stale
        showImage: false
    }

    ColumnLayout {
        anchors { fill: parent; margins: 28 }
        spacing: 16

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 2
                Text {
                    text: "J.A.R.V.I.S."
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 25
                    font.weight: Font.ExtraBold
                    font.letterSpacing: 2.2
                    color: "#d8f7ff"
                }
                Text {
                    text: "MARK II DESKTOP INTERFACE"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.2
                    color: "#6e8aa4"
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 28
                radius: 14
                color: "#07111f"
                border.width: 1
                border.color: root.stateColor
                Text {
                    anchors.centerIn: parent
                    text: root.effectivePresence.toUpperCase()
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 9
                    font.weight: Font.ExtraBold
                    color: root.stateColor
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#1a4560" }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            HealthPip { label: "VOICE"; service: "voice" }
            HealthPip { label: "BRAIN"; service: "core" }
            HealthPip { label: "AGENTS"; service: "agents" }
            HealthPip { label: "PERCEPT"; service: "perception" }
            PrivacyPip { label: "EARS"; kind: "ears" }
            PrivacyPip { label: "EYES"; kind: "eyes" }
        }

        Text {
            Layout.fillWidth: true
            text: root.stale ? "Runtime signal is stale. Start Jarvis to restore live telemetry." : root.reason
            wrapMode: Text.WordWrap
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 13
            color: "#b9d3df"
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 10
            rowSpacing: 10

            StatusTile { label: "VOICE"; value: root.speaking ? "SPEAKING" : (root.wakeActive ? "LISTENING" : (root.listening ? "ARMED" : "QUIET")) }
            StatusTile { label: "QUIET MODE"; value: root.quietReason }
            StatusTile { label: "LOCK"; value: root.context.locked ? "SECURED" : "CLEAR" }
            StatusTile { label: "CALL"; value: root.context.call_active ? "ACTIVE" : "CLEAR" }
            StatusTile { label: "GAME"; value: root.context.gaming ? "ACTIVE" : "CLEAR" }
            StatusTile { label: "CLASS"; value: root.activeClass }
            StatusTile { label: "JOBS"; value: root.activeJobCount > 0 ? root.activeJobLabel : "CLEAR" }
            StatusTile { label: "WATCHING"; value: root.watchingCount > 0 ? (root.watchingCount + " ACTIVE") : "CLEAR" }
            StatusTile { label: "QUEUED"; value: root.queuedCount > 0 ? (root.queuedCount + " PENDING") : "CLEAR" }
            StatusTile { label: "MOBILE"; value: root.mobileDeviceLabel }
            StatusTile { label: "MEMORY"; value: root.pendingMemories > 0 ? (root.pendingMemories + " PENDING") : "CLEAR" }
            StatusTile { label: "EARS"; value: root.privacyLabel("ears") }
            StatusTile { label: "EYES"; value: root.privacyLabel("eyes") }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            Text {
                text: "ACTIVE WINDOW"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 9
                font.weight: Font.ExtraBold
                color: "#6e8aa4"
            }
            Text {
                Layout.fillWidth: true
                text: root.activeWindow
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 11
                color: "#d3edf4"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.currentTask.length > 0
            spacing: 6
            Text {
                text: "CURRENT TASK"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 9
                font.weight: Font.ExtraBold
                color: "#6e8aa4"
            }
            Text {
                Layout.fillWidth: true
                text: root.currentTask
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 11
                color: "#d3edf4"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.activeJobCount > 0
            spacing: 6
            Text {
                text: "ACTIVE JOB"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 9
                font.weight: Font.ExtraBold
                color: "#f8c46a"
            }
            Text {
                Layout.fillWidth: true
                text: root.activeJobPrompt
                wrapMode: Text.WordWrap
                maximumLineCount: 4
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 11
                color: "#ffe0a3"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.pendingApprovals.length > 0
            spacing: 8
            Text {
                text: "PENDING APPROVAL"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 9
                font.weight: Font.ExtraBold
                color: "#f8c46a"
            }

            Repeater {
                model: root.pendingApprovals.slice(0, 3)
                delegate: ApprovalCard {
                    approvalId: modelData.id || ""
                    summary: modelData.summary || "Approval required."
                    risk: modelData.risk || "unknown"
                    expiresAt: modelData.expires_at || ""
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.pendingMemories > 0
            spacing: 8
            Text {
                text: "MEMORY REVIEW" + (root.memoryReview.prompt ? (" • " + root.memoryReview.prompt) : "")
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 9
                font.weight: Font.ExtraBold
                color: "#82f7bd"
            }

            Repeater {
                model: (root.memoryReview.pending || []).slice(0, 5)
                delegate: MemoryCard {
                    memoryId: String(modelData.id || "")
                    content: modelData.content || ""
                    confidence: modelData.confidence || 0
                    category: modelData.category || ""
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.activityToday.length > 0
            spacing: 7
            Text {
                text: "TODAY"
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 9
                font.weight: Font.ExtraBold
                color: "#6e8aa4"
            }

            Repeater {
                model: root.activityToday.slice(0, 5)
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.preferredWidth: 42
                        text: root.activityTime(modelData)
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 9
                        font.weight: Font.ExtraBold
                        color: "#7cafff"
                    }
                    Text {
                        Layout.preferredWidth: 92
                        text: root.activityApps(modelData)
                        elide: Text.ElideRight
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 9
                        color: "#82f7bd"
                    }
                    Text {
                        Layout.fillWidth: true
                        text: modelData.summary || ""
                        elide: Text.ElideRight
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 9
                        color: "#d3edf4"
                    }
                }
            }
        }

        Text {
            text: "CONTROL"
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 9
            font.weight: Font.ExtraBold
            color: "#6e8aa4"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            ControlButton { label: "WAKE"; operation: "wake"; accent: "#7cafff" }
            ControlButton { label: "MUTE"; operation: "mute"; accent: "#ff9d66" }
            ControlButton { label: "SLEEP"; operation: "sleep"; accent: "#76819a" }
        }

        Item { Layout.fillHeight: true }

        Text {
            Layout.fillWidth: true
            text: "Screen capture, desktop actions, and agent delegation remain confirmation-gated by the Mark II runtime."
            wrapMode: Text.WordWrap
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 10
            color: "#68829a"
        }
    }

    component StatusTile: Rectangle {
        required property string label
        required property string value

        Layout.fillWidth: true
        Layout.preferredHeight: 58
        radius: 10
        color: "#101f33"
        border.color: "#183d55"
        border.width: 1

        Column {
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 12 }
            spacing: 4

            Text {
                text: label
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 8
                font.weight: Font.ExtraBold
                color: "#6e8aa4"
            }

            Text {
                width: parent.width
                text: value
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: "#cfecf2"
            }
        }
    }

    component HealthPip: Rectangle {
        required property string label
        required property string service

        Layout.fillWidth: true
        Layout.preferredHeight: 28
        radius: 14
        color: "#101f33"
        border.color: root.serviceColor(service)
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 7

            Rectangle {
                width: 7
                height: 7
                radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: root.serviceColor(service)
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: label + " " + root.serviceState(service).toUpperCase()
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 8
                font.weight: Font.ExtraBold
                color: "#cfecf2"
            }
        }
    }

    component PrivacyPip: Rectangle {
        required property string label
        required property string kind

        Layout.fillWidth: true
        Layout.preferredHeight: 28
        radius: 14
        color: "#101f33"
        border.color: root.privacyColor(kind)
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 7

            Rectangle {
                width: 7
                height: 7
                radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: root.privacyColor(kind)
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: label + " " + root.privacyLabel(kind)
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 8
                font.weight: Font.ExtraBold
                color: "#cfecf2"
            }
        }
    }

    component ControlButton: Rectangle {
        required property string label
        required property string operation
        property color accent: "#7cafff"

        Layout.fillWidth: true
        Layout.preferredHeight: 38
        radius: 9
        color: hover.containsMouse ? "#183b56" : "#102d45"
        border.color: hover.containsMouse ? accent : "#267ba4"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: label
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 10
            font.weight: Font.ExtraBold
            color: hover.containsMouse ? accent : "#d8f7ff"
        }

        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.runControl(operation)
        }
    }

    component ApprovalCard: Rectangle {
        id: approvalCard
        required property string approvalId
        required property string summary
        required property string risk
        required property string expiresAt

        Layout.fillWidth: true
        Layout.preferredHeight: 104
        radius: 12
        color: "#151f2b"
        border.color: "#8f6b25"
        border.width: 1

        // Attention breath — approvals gently pulse their border so they read as "waiting on you".
        SequentialAnimation on border.color {
            running: true
            loops: Animation.Infinite
            ColorAnimation { to: "#c79338"; duration: 900; easing.type: Easing.InOutSine }
            ColorAnimation { to: "#8f6b25"; duration: 900; easing.type: Easing.InOutSine }
        }

        // Mount transition.
        opacity: 0
        Component.onCompleted: mountIn.start()
        NumberAnimation { id: mountIn; target: approvalCard; property: "opacity"; from: 0; to: 1; duration: 260; easing.type: Easing.OutCubic }

        ColumnLayout {
            anchors { fill: parent; margins: 12 }
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: risk.toUpperCase()
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 8
                    font.weight: Font.ExtraBold
                    color: "#f8c46a"
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: approvalId.slice(0, 12)
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 8
                    color: "#6e8aa4"
                }
            }

            Text {
                Layout.fillWidth: true
                text: summary
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 10
                color: "#ffe0a3"
            }

            Text {
                Layout.fillWidth: true
                text: expiresAt ? ("EXPIRES " + expiresAt) : "NO EXPIRY DATA"
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 8
                color: "#6e8aa4"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                ApprovalButton { label: "APPROVE"; accent: "#82f7bd"; onClicked: root.resolveApproval(approvalCard.approvalId, true) }
                ApprovalButton { label: "DENY"; accent: "#ff7a7a"; onClicked: root.resolveApproval(approvalCard.approvalId, false) }
            }
        }
    }

    component ApprovalButton: Rectangle {
        required property string label
        property color accent: "#82f7bd"
        signal clicked()

        Layout.fillWidth: true
        Layout.preferredHeight: 24
        radius: 7
        color: hover.containsMouse ? "#223346" : "#102333"
        border.color: hover.containsMouse ? accent : "#31516a"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: label
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 8
            font.weight: Font.ExtraBold
            color: hover.containsMouse ? accent : "#d8f7ff"
        }

        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component MemoryCard: Rectangle {
        id: memoryCard
        required property string memoryId
        required property string content
        property real confidence: 0
        property string category: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 96
        radius: 12
        color: "#11251f"
        border.color: "#2f7f62"
        border.width: 1

        opacity: 0
        Component.onCompleted: memMountIn.start()
        NumberAnimation { id: memMountIn; target: memoryCard; property: "opacity"; from: 0; to: 1; duration: 260; easing.type: Easing.OutCubic }

        ColumnLayout {
            anchors { fill: parent; margins: 12 }
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: ("MEMORY " + memoryId).toUpperCase()
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 8
                    font.weight: Font.ExtraBold
                    color: "#82f7bd"
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: (category ? category.toUpperCase() + " • " : "") + Number(confidence).toFixed(2)
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 8
                    color: "#6e8aa4"
                }
            }

            Text {
                Layout.fillWidth: true
                text: content
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 10
                color: "#d8f7ff"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                ApprovalButton { label: "KEEP"; accent: "#82f7bd"; onClicked: root.resolveMemory(memoryCard.memoryId, true) }
                ApprovalButton { label: "REJECT"; accent: "#ff7a7a"; onClicked: root.resolveMemory(memoryCard.memoryId, false) }
            }
        }
    }
}
