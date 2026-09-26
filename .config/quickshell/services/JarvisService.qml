pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string statusPath: homeDir + "/.cache/jarvis-mark-ii/status.json"
    readonly property string projectDir: homeDir + "/Projects/Jarvis"
    readonly property string executable: projectDir + "/.venv/bin/jarvis"

    property bool runtimeAvailable: false
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
    property real clockMs: Date.now()
    property real wakeUntilMs: 0
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
    property int streamConsumers: 0
    property int retryDelay: 2000
    property string lastAction: ""
    property bool actionPulse: false

    readonly property bool shouldStream: runtimeAvailable && streamConsumers > 0
    readonly property bool streamRunning: busStream.running
    readonly property bool retryScheduled: streamRestartTimer.running
    readonly property bool wakeActive: listening || clockMs < wakeUntilMs
    readonly property bool stale: {
        var stamp = Date.parse(updatedAt);
        return streamStale || isNaN(stamp) || clockMs - stamp > 15000;
    }
    readonly property string effectivePresence: stale ? "offline" : rawPresence
    readonly property bool activeish: effectivePresence === "active"
        || effectivePresence === "speaking" || effectivePresence === "thinking"
    readonly property bool ambientEnabled: perception.ambient_enabled === true
    readonly property string screenMode: perception.screen_mode || "off"

    function acquireStream() { streamConsumers += 1; }
    function releaseStream() { streamConsumers = Math.max(0, streamConsumers - 1); }

    function reconcileStream() {
        if (shouldStream) {
            if (!busStream.running && !streamRestartTimer.running)
                busStream.running = true;
        } else {
            streamRestartTimer.stop();
            retryDelay = 2000;
            streamStale = false;
            if (busStream.running)
                busStream.running = false;
        }
    }

    function noteAction(action) {
        lastAction = action;
        actionPulse = true;
        pulseTimer.restart();
    }

    function applyStatus(status) {
        rawPresence = status.presence || "offline";
        reason = status.reason || "Runtime unavailable.";
        updatedAt = status.updated_at || "";
        currentTask = status.current_task || "";
        context = status.context || ({});
        services = status.services || ({});
        perception = status.perception || ({});
        listening = status.listening === true;
        speaking = status.speaking === true;
        pendingApprovals = status.pending_approvals || [];
        activityToday = status.activity_today || [];
        pendingMemories = status.pending_memories || 0;
        memoryReview = status.memory_review || ({});
        initiative = status.initiative || ({});
        watchingCount = initiative.watching || 0;
        queuedCount = initiative.queued || 0;
        clockMs = Date.now();
    }

    function markOffline() {
        rawPresence = "offline";
        reason = "Runtime unavailable.";
        updatedAt = "";
        currentTask = "";
        context = ({});
        services = ({});
        perception = ({});
        listening = false;
        speaking = false;
        pendingApprovals = [];
        activityToday = [];
        pendingMemories = 0;
        memoryReview = ({});
        initiative = ({});
        watchingCount = 0;
        queuedCount = 0;
        clockMs = Date.now();
    }

    function eventStamp(event) {
        return event && event.ts ? new Date(event.ts * 1000).toISOString() : new Date().toISOString();
    }

    function derivedPresence() {
        if (speaking) return "speaking";
        if (context.locked) return "asleep";
        if (context.call_active || context.gaming) return "muted";
        return "active";
    }

    function copyMap(source) {
        var result = {};
        var keys = Object.keys(source || {});
        for (var i = 0; i < keys.length; i++)
            result[keys[i]] = source[keys[i]];
        return result;
    }

    function applyHealthEvent(data) {
        if (!data || !data.service)
            return;
        var service = String(data.service).toLowerCase();
        if (service !== "voice" && service !== "core" && service !== "agents" && service !== "perception")
            return;
        var next = copyMap(services);
        next[service] = data.ok === true ? "ok" : "down";
        services = next;
    }

    function refreshActiveJobs() {
        var active = [];
        var keys = Object.keys(activeJobs);
        for (var i = 0; i < keys.length; i++) {
            var job = activeJobs[keys[i]];
            if (job.status === "running" || job.status === "queued")
                active.push(job);
        }
        activeJobCount = active.length;
        if (active.length > 0) {
            var first = active[0];
            activeJobLabel = ((first.adapter || "worker") + " • " + (first.status || "active")).toUpperCase();
            activeJobPrompt = first.prompt_summary || first.prompt || "";
        } else {
            activeJobLabel = "CLEAR";
            activeJobPrompt = "";
        }
    }

    function applyAgentEvent(type, data) {
        if (!data || !data.job_id)
            return;
        var jobs = copyMap(activeJobs);
        if (type === "agent.job.completed" || type === "agent.job.failed"
                || data.status === "succeeded" || data.status === "failed" || data.status === "blocked")
            delete jobs[data.job_id];
        else
            jobs[data.job_id] = data;
        activeJobs = jobs;
        refreshActiveJobs();
    }

    function upsertApproval(data) {
        if (!data || !data.approval_id)
            return;
        var approvals = pendingApprovals.filter(function(item) { return item.id !== data.approval_id; });
        approvals.unshift({
            "id": data.approval_id,
            "summary": data.summary || "Approval required.",
            "risk": data.risk || "unknown",
            "expires_at": data.expires_at || ""
        });
        pendingApprovals = approvals;
    }

    function removeApproval(data) {
        if (data && data.approval_id)
            pendingApprovals = pendingApprovals.filter(function(item) { return item.id !== data.approval_id; });
    }

    function applyBusEvent(line) {
        if (!line || !line.length)
            return;
        try {
            var event = JSON.parse(line);
            var data = event.data || {};
            streamStale = false;
            retryDelay = 2000;
            clockMs = Date.now();
            if (event.type === "context.changed") {
                context = {
                    "locked": data.locked === true,
                    "call_active": data.call_active === true,
                    "gaming": data.gaming === true,
                    "active_window": data.active_window || "",
                    "active_class": data.active_class || ""
                };
                rawPresence = data.presence || derivedPresence();
                reason = "Runtime telemetry live.";
                updatedAt = eventStamp(event);
            } else if (event.type === "voice.wake") {
                wakeUntilMs = Date.now() + 6000;
                updatedAt = eventStamp(event);
            } else if (event.type === "speech.playback.started") {
                speaking = true;
                wakeUntilMs = 0;
                rawPresence = "speaking";
                updatedAt = eventStamp(event);
            } else if (event.type === "speech.playback.finished") {
                speaking = false;
                rawPresence = derivedPresence();
                updatedAt = eventStamp(event);
            } else if (event.type === "approval.requested") {
                upsertApproval(data);
            } else if (event.type === "approval.resolved") {
                removeApproval(data);
            } else if (event.type.indexOf("agent.job.") === 0) {
                applyAgentEvent(event.type, data);
            } else if (event.type === "health.heartbeat") {
                applyHealthEvent(data);
            } else if (event.type === "ambient.state") {
                var ambient = copyMap(perception);
                ambient.ambient_enabled = data.enabled === true;
                ambient.ambient_reason = data.reason || "";
                perception = ambient;
            } else if (event.type === "screen.mode") {
                var screen = copyMap(perception);
                screen.screen_mode = data.mode || "off";
                perception = screen;
            }
        } catch (_) {
        }
    }

    function runControl(operation) {
        if (!runtimeAvailable || controlProcess.running
                || (operation !== "wake" && operation !== "mute" && operation !== "sleep"))
            return;
        noteAction(operation.toUpperCase());
        controlProcess.command = [executable, "control", operation];
        controlProcess.running = true;
    }

    function resolveApproval(approvalId, approve) {
        if (!runtimeAvailable || !approvalId || approvalProcess.running)
            return;
        approvalProcess.command = [executable, approve ? "approve" : "deny", approvalId];
        approvalProcess.running = true;
    }

    function resolveMemory(memoryId, confirm) {
        if (!runtimeAvailable || !memoryId || memoryProcess.running)
            return;
        memoryProcess.command = [executable, "memories", confirm ? "confirm" : "reject", memoryId];
        memoryProcess.running = true;
    }

    onShouldStreamChanged: reconcileStream()

    FileView {
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

        function sync() {
            root.applyStatus({
                "presence": statusStore.presence,
                "reason": statusStore.reason,
                "updated_at": statusStore.updated_at,
                "current_task": statusStore.current_task,
                "context": statusStore.context,
                "services": statusStore.services,
                "perception": statusStore.perception,
                "listening": statusStore.listening,
                "speaking": statusStore.speaking,
                "pending_approvals": statusStore.pending_approvals,
                "activity_today": statusStore.activity_today,
                "pending_memories": statusStore.pending_memories,
                "memory_review": statusStore.memory_review,
                "initiative": statusStore.initiative
            });
        }

        onLoaded: sync()
        onAdapterUpdated: sync()
        onLoadFailed: root.markOffline()
    }

    Process {
        command: ["test", "-x", root.executable]
        running: true
        onExited: function(exitCode, exitStatus) {
            root.runtimeAvailable = exitCode === 0;
            root.reconcileStream();
        }
    }

    Process {
        id: busStream
        command: [root.executable, "stream", "--filter",
            "context.,approval.,agent.,speech.,health.,ambient.,screen.,voice.wake"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) { root.applyBusEvent(line); }
        }
        onRunningChanged: {
            if (running) {
                root.streamStale = false;
            } else if (root.shouldStream) {
                root.streamStale = true;
                streamRestartTimer.restart();
            }
        }
    }

    Timer {
        id: streamRestartTimer
        interval: root.retryDelay
        onTriggered: {
            if (root.shouldStream && !busStream.running) {
                busStream.running = true;
                root.retryDelay = Math.min(30000, root.retryDelay * 2);
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: root.updatedAt !== "" || root.streamConsumers > 0
        onTriggered: root.clockMs = Date.now()
    }

    Timer { id: pulseTimer; interval: 650; onTriggered: root.actionPulse = false }
    Process { id: controlProcess; workingDirectory: root.projectDir; running: false }
    Process { id: approvalProcess; workingDirectory: root.projectDir; running: false }
    Process { id: memoryProcess; workingDirectory: root.projectDir; running: false }
}
