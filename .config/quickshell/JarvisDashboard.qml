// JarvisDashboard.qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import "services" as Backend

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

    readonly property var jarvis: Backend.JarvisService
    property bool streamClaimed: false

    readonly property bool runtimeAvailable: jarvis.runtimeAvailable
    readonly property string rawPresence: jarvis.rawPresence
    readonly property string reason: jarvis.reason
    readonly property string updatedAt: jarvis.updatedAt
    readonly property string currentTask: jarvis.currentTask
    readonly property var context: jarvis.context
    readonly property var services: jarvis.services
    readonly property var perception: jarvis.perception
    readonly property bool listening: jarvis.listening
    readonly property bool speaking: jarvis.speaking
    readonly property bool streamStale: jarvis.streamStale
    readonly property real clockMs: jarvis.clockMs
    readonly property real wakeUntilMs: jarvis.wakeUntilMs
    readonly property bool wakeActive: jarvis.wakeActive
    readonly property var activeJobs: jarvis.activeJobs
    readonly property int activeJobCount: jarvis.activeJobCount
    readonly property string activeJobLabel: jarvis.activeJobLabel
    readonly property string activeJobPrompt: jarvis.activeJobPrompt
    readonly property int mobileDeviceCount: jarvis.mobileDeviceCount
    readonly property string mobileDeviceLabel: jarvis.mobileDeviceLabel
    readonly property var pendingApprovals: jarvis.pendingApprovals
    readonly property var activityToday: jarvis.activityToday
    readonly property int pendingMemories: jarvis.pendingMemories
    readonly property var memoryReview: jarvis.memoryReview
    readonly property var initiative: jarvis.initiative
    readonly property int watchingCount: jarvis.watchingCount
    readonly property int queuedCount: jarvis.queuedCount

    function reconcileStreamClaim() {
        if (open && !streamClaimed) {
            jarvis.acquireStream()
            streamClaimed = true
        } else if (!open && streamClaimed) {
            jarvis.releaseStream()
            streamClaimed = false
        }
    }

    onOpenChanged: reconcileStreamClaim()
    Component.onCompleted: reconcileStreamClaim()
    Component.onDestruction: {
        if (streamClaimed)
            jarvis.releaseStream()
    }

    readonly property bool stale: jarvis.stale
    readonly property string effectivePresence: jarvis.effectivePresence
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
    readonly property bool ambientEnabled: jarvis.ambientEnabled
    readonly property string screenMode: jarvis.screenMode

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

    function runControl(operation) {
        jarvis.runControl(operation)
    }

    function resolveApproval(approvalId, approve) {
        jarvis.resolveApproval(approvalId, approve)
    }

    function resolveMemory(memoryId, confirm) {
        jarvis.resolveMemory(memoryId, confirm)
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
