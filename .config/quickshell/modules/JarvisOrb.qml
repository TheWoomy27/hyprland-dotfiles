// JarvisOrb.qml — the living visualizer.
// Three visually distinct states, smoothly cross-tweened:
//   idle      → a slow breathing core (near-zero cost, safe to leave running)
//   listening → a bright, focused inward pulse (fast, attentive) + ignited ring
//   speaking  → concentric rings riding a synthesized speech envelope
// Drives entirely off booleans + accent color the parent already computes.
pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: orb

    // ---- inputs (bind these from the surface) ----
    property color accent: "#7cafff"
    property bool speaking: false
    property bool listening: false
    property bool stale: false
    property real levelHint: -1        // 0..1 real speech level if ever available; <0 = synthesize
    property bool showImage: true

    // ---- derived envelope ----
    // When speaking without a real level, synthesize an organic 0..1 envelope so
    // the rings never look like a fixed loop. Cheap: one Timer, no per-frame audio.
    property real _env: 0.0
    readonly property real level: speaking ? (levelHint >= 0 ? levelHint : _env) : 0.0

    Timer {
        // Only ticks while speaking — idle cost is zero.
        interval: 55
        running: orb.speaking && orb.levelHint < 0
        repeat: true
        property real phase: 0
        onTriggered: {
            // Sum of a few detuned sines + jitter → speech-like, non-repeating.
            phase += 0.28
            var s = 0.5
                + 0.30 * Math.sin(phase)
                + 0.14 * Math.sin(phase * 2.13 + 1.1)
                + 0.10 * Math.sin(phase * 3.71 + 2.7)
            s += (Math.random() - 0.5) * 0.12
            orb._env = Math.max(0.05, Math.min(1.0, s))
        }
    }
    // Ease the envelope back to rest when speech stops.
    Behavior on _env { NumberAnimation { duration: 90 } }
    onSpeakingChanged: if (!speaking) _env = 0.0

    readonly property color _accent: stale ? "#3d4a5e" : accent

    // ---- outer ignition ring (listening = attentive halo) ----
    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: width
        radius: width / 2
        color: "transparent"
        border.width: orb.listening ? 2 : 1
        border.color: orb._accent
        opacity: orb.listening ? 0.9 : (orb.speaking ? 0.5 : 0.28)
        scale: orb.listening ? 1.0 : 0.92
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

        // Listening: a quick focused breathing on the ring itself.
        SequentialAnimation on opacity {
            running: orb.listening
            loops: Animation.Infinite
            NumberAnimation { to: 0.45; duration: 620; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.95; duration: 620; easing.type: Easing.InOutSine }
        }
    }

    // ---- speaking rings: three concentric rings scaled by the envelope ----
    Repeater {
        model: 3
        Rectangle {
            required property int index
            anchors.centerIn: parent
            property real base: 0.5 + index * 0.18
            width: parent.width * (base + orb.level * (0.20 + index * 0.12))
            height: width
            radius: width / 2
            color: "transparent"
            border.width: index === 0 ? 2 : 1
            border.color: orb._accent
            opacity: orb.speaking ? (0.55 - index * 0.15) * (0.5 + orb.level * 0.5) : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    // ---- idle breathing core ----
    Rectangle {
        id: core
        anchors.centerIn: parent
        width: parent.width * 0.40
        height: width
        radius: width / 2
        color: Qt.rgba(orb._accent.r, orb._accent.g, orb._accent.b, 0.16)
        border.width: 1
        border.color: orb._accent

        // Scale: gentle when idle, punchier with speech level, tight when listening.
        scale: {
            if (orb.speaking) return 1.0 + orb.level * 0.32
            if (orb.listening) return 1.08
            return 1.0
        }
        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

        // The always-on breath — cheap, and the whole reason idle still feels alive.
        SequentialAnimation on opacity {
            running: !orb.speaking && !orb.listening
            loops: Animation.Infinite
            NumberAnimation { to: 0.55; duration: 1800; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.92; duration: 1800; easing.type: Easing.InOutSine }
        }
        opacity: (orb.speaking || orb.listening) ? 0.95 : 0.75
    }

    // ---- glyph / avatar in the very center ----
    Image {
        anchors.centerIn: parent
        source: "jarvis.png"
        width: parent.width * 0.42
        height: width
        sourceSize.width: 96
        sourceSize.height: 96
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        visible: orb.showImage
        opacity: orb.stale ? 0.30 : 0.9
    }
}
