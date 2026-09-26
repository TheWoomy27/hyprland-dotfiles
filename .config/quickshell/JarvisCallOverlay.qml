// JarvisCallOverlay.qml
import Quickshell
import QtQuick
import "services" as Backend

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

    readonly property var jarvis: Backend.JarvisService
    property bool streamClaimed: false
    readonly property bool runtimeAvailable: jarvis.runtimeAvailable
    readonly property string rawPresence: jarvis.rawPresence
    readonly property string reason: jarvis.reason
    readonly property string updatedAt: jarvis.updatedAt
    readonly property var context: jarvis.context
    readonly property bool streamStale: jarvis.streamStale
    readonly property real clockMs: jarvis.clockMs

    function reconcileStreamClaim() {
        if (modeNotificationsEnabled && !streamClaimed) {
            jarvis.acquireStream()
            streamClaimed = true
        } else if (!modeNotificationsEnabled && streamClaimed) {
            jarvis.releaseStream()
            streamClaimed = false
        }
    }

    onModeNotificationsEnabledChanged: reconcileStreamClaim()
    Component.onCompleted: reconcileStreamClaim()
    Component.onDestruction: {
        if (streamClaimed)
            jarvis.releaseStream()
    }

    readonly property bool stale: jarvis.stale
    readonly property bool quietActive: !stale && (context.call_active === true || context.gaming === true)
    readonly property color accent: context.call_active ? "#49dff9" : "#f8c46a"
    readonly property string title: context.call_active ? "COMMUNICATION CHANNEL ACTIVE" : "GAME MODE DETECTED"
    readonly property string detail: context.call_active
                                     ? "Voice output muted until the call concludes."
                                     : "Jarvis is quiet while the game is active."

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
