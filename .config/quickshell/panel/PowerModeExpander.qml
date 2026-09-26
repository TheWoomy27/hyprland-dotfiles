// panel/PowerModeExpander.qml — native power-profiles-daemon state
import QtQuick
import QtQuick.Layouts
import "../services" as Backend

Item {
    id: root
    Layout.minimumWidth: 140
    implicitHeight: 48

    readonly property string activeProfile: Backend.PowerProfileService.activeProfile
    property bool expanded: false
    readonly property var profiles: Backend.PowerProfileService.profiles

    function iconFor(profile) {
        for (var i = 0; i < profiles.length; i++) {
            if (profiles[i].id === profile)
                return profiles[i].icon;
        }
        return "\uf201";
    }

    function setProfile(profile) {
        Backend.PowerProfileService.setProfile(profile);
        root.expanded = false;
    }

    ExpandableToggle {
        anchors.fill: parent
        enabled: Backend.PowerProfileService.available
        opacity: enabled ? 1.0 : 0.45
        icon: root.iconFor(root.activeProfile)
        label: "Power"
        active: root.activeProfile === "performance"
        expanded: root.expanded
        onToggled: root.expanded = !root.expanded
        onExpandClicked: root.expanded = !root.expanded
    }
}
