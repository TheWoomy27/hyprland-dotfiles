// panel/WifiExpander.qml — native NetworkManager state and on-demand scanning
import QtQuick
import "../services" as Backend

Item {
    id: root
    implicitHeight: 48

    readonly property string ssid: Backend.NetworkService.ssid
    readonly property var networks: Backend.NetworkService.networkRows
    property bool expanded: false
    property bool scannerClaimed: false

    onExpandedChanged: {
        if (expanded && !scannerClaimed) {
            Backend.NetworkService.acquireScanner();
            scannerClaimed = true;
        } else if (!expanded && scannerClaimed) {
            Backend.NetworkService.releaseScanner();
            scannerClaimed = false;
        }
    }

    Component.onDestruction: {
        if (scannerClaimed)
            Backend.NetworkService.releaseScanner();
    }

    function toggleWifi() {
        Backend.NetworkService.toggleWifi();
    }

    function scan() {
        if (!scannerClaimed) {
            Backend.NetworkService.acquireScanner();
            scannerClaimed = true;
        }
    }

    ExpandableToggle {
        anchors.fill: parent
        icon: "\uf1eb"
        iconPixelSize: 20
        iconHoverScale: 1.32
        chevronHoverScale: 1.28
        label: root.ssid !== "" ? root.ssid : "Wi-Fi"
        active: Backend.NetworkService.connType === "wifi"
        expanded: root.expanded
        onToggled: root.toggleWifi()
        onExpandClicked: root.expanded = !root.expanded
    }
}
