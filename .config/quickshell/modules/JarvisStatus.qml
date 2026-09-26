// modules/JarvisStatus.qml
// Left click: dashboard
// Right click: mute/wake
// Middle click: sleep
import QtQuick
import "../services" as Backend

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

    readonly property var jarvis: Backend.JarvisService
    readonly property string rawPresence: jarvis.rawPresence
    readonly property string reason: jarvis.reason
    readonly property string updatedAt: jarvis.updatedAt
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
    readonly property string lastAction: jarvis.lastAction
    readonly property bool actionPulse: jarvis.actionPulse

    readonly property bool stale: jarvis.stale
    readonly property string effectivePresence: jarvis.effectivePresence
    readonly property bool activeish: jarvis.activeish
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
    readonly property bool ambientEnabled: jarvis.ambientEnabled
    readonly property string screenMode: jarvis.screenMode

    signal toggleDashboard()

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

    function runControl(operation) {
        jarvis.runControl(operation)
    }

    Component.onCompleted: jarvis.acquireStream()
    Component.onDestruction: jarvis.releaseStream()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onPressed: function(mouse) {
            mouse.accepted = true
            if (mouse.button === Qt.LeftButton) {
                root.jarvis.noteAction("DASH")
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
