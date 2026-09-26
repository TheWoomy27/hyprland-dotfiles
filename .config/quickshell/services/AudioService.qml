pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var audioNodes: Pipewire.nodes.values.filter(function(node) {
        return node && !node.isStream
            && (node.type === PwNodeType.AudioSink || node.type === PwNodeType.AudioSource);
    })
    readonly property var sinks: audioNodes.filter(function(node) {
        return node.type === PwNodeType.AudioSink;
    })
    readonly property var sources: audioNodes.filter(function(node) {
        return node.type === PwNodeType.AudioSource;
    })

    readonly property bool available: !!(Pipewire.ready && sink && sink.ready && sink.audio)
    readonly property bool muted: available ? sink.audio.muted : false
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property string sinkName: sink ? (sink.description || sink.nickname || sink.name) : "No output"
    readonly property string sinkType: {
        var label = sinkName.toLowerCase();
        return label.indexOf("headphone") >= 0 || label.indexOf("headset") >= 0
            || label.indexOf("earphone") >= 0 || label.indexOf("earbud") >= 0
            ? "headset" : "speaker";
    }

    function setVolume(value) {
        if (!available)
            return;
        sink.audio.volume = Math.max(0, Math.min(1.5, value));
    }

    function adjustVolume(delta) {
        setVolume(volume + delta);
    }

    function toggleMute() {
        if (available)
            sink.audio.muted = !sink.audio.muted;
    }

    function setDefaultSink(node) {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function cycleSink() {
        if (sinks.length < 2)
            return;

        var current = sinks.indexOf(sink);
        setDefaultSink(sinks[(current + 1 + sinks.length) % sinks.length]);
    }

    PwObjectTracker {
        // Tracking is what asks Quickshell to keep node properties and volume live.
        objects: Pipewire.nodes.values
    }
}
