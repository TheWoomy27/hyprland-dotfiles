pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    property bool daemonAvailable: false
    property string probeResult: ""
    readonly property bool available: backendLoader.item !== null
    readonly property bool performanceAvailable: available && backendLoader.item.performanceAvailable
    readonly property string activeProfile: available ? backendLoader.item.activeProfile : "balanced"
    readonly property var profiles: available ? backendLoader.item.profiles : []

    function setProfile(profile) {
        if (available)
            backendLoader.item.setProfile(profile);
    }

    Process {
        command: ["systemctl", "is-enabled", "power-profiles-daemon.service"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) { root.probeResult = line.trim(); }
        }
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                if (root.probeResult === "")
                    root.probeResult = line.trim();
            }
        }
        onExited: function(exitCode, exitStatus) {
            var state = root.probeResult.toLowerCase();
            root.daemonAvailable = state !== "" && state !== "masked"
                && state.indexOf("not-found") < 0 && state.indexOf("failed") < 0;
        }
    }

    Loader {
        id: backendLoader
        active: root.daemonAvailable
        sourceComponent: Component {
            QtObject {
                readonly property int profile: PowerProfiles.profile
                readonly property bool performanceAvailable: PowerProfiles.hasPerformanceProfile
                readonly property string activeProfile: {
                    if (profile === PowerProfile.Performance)
                        return "performance";
                    if (profile === PowerProfile.PowerSaver)
                        return "power-saver";
                    return "balanced";
                }
                readonly property var profiles: {
                    var items = [];
                    if (performanceAvailable)
                        items.push({ "id": "performance", "label": "Performance", "icon": "\uf0e7" });
                    items.push({ "id": "balanced", "label": "Balanced", "icon": "\uf201" });
                    items.push({ "id": "power-saver", "label": "Power Saver", "icon": "\uf06c" });
                    return items;
                }

                function setProfile(profile) {
                    if (profile === "performance" && performanceAvailable)
                        PowerProfiles.profile = PowerProfile.Performance;
                    else if (profile === "power-saver")
                        PowerProfiles.profile = PowerProfile.PowerSaver;
                    else
                        PowerProfiles.profile = PowerProfile.Balanced;
                }
            }
        }
    }
}
