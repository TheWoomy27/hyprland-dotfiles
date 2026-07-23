// Theme.qml — single source of truth for the Jarvis HUD look.
// Instantiate per surface:  Theme { id: theme }
import QtQuick

QtObject {
    // Surfaces
    readonly property color bg0: "#08111f"        // outermost panel
    readonly property color bg1: "#0d1728"        // inner panel
    readonly property color bg2: "#101f33"        // tiles / cards
    readonly property color bg3: "#0a1626"        // wells, inset areas
    readonly property color line: "#183d55"       // hairlines
    readonly property color lineSoft: "#14304a"

    // Text
    readonly property color textBright: "#d8f7ff"
    readonly property color textBody: "#b9d3df"
    readonly property color textDim: "#6e8aa4"
    readonly property color textFaint: "#46556a"

    // Presence accents (canonical — keep in sync with pill + dashboard)
    readonly property color active: "#7cafff"
    readonly property color speaking: "#82f7bd"
    readonly property color listening: "#9be8ff"
    readonly property color thinking: "#f8c46a"
    readonly property color muted: "#ff9d66"
    readonly property color asleep: "#76819a"
    readonly property color offline: "#65758d"
    readonly property color danger: "#ff7a7a"
    readonly property color warn: "#f8c46a"
    readonly property color ok: "#82f7bd"

    // Type
    readonly property string fontFamily: "JetBrainsMono Nerd Font Propo"

    // Motion (single place to tune the whole HUD's tempo)
    readonly property int motionFast: 140
    readonly property int motionMid: 240
    readonly property int motionSlow: 420
    readonly property int breathePeriod: 3600

    function presenceColor(presence, isListening) {
        if (presence === "speaking") return speaking
        if (isListening) return listening
        if (presence === "active") return active
        if (presence === "thinking") return thinking
        if (presence === "muted") return muted
        if (presence === "asleep") return asleep
        return offline
    }

    function withAlpha(base, alpha) {
        return Qt.rgba(base.r, base.g, base.b, alpha)
    }
}
