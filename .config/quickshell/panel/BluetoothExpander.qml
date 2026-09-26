// panel/BluetoothExpander.qml — native BlueZ state
import QtQuick
import "../services" as Backend

Item {
    id: root
    implicitHeight: 48

    readonly property bool btOn: Backend.BluetoothService.enabled
    readonly property var devices: Backend.BluetoothService.connectedRows
    property bool expanded: false

    function scan() {
        // Connected devices are maintained live by BlueZ; retained for callers.
    }

    ExpandableToggle {
        anchors.fill: parent
        icon: "\uf294"
        iconPixelSize: 21
        iconHoverScale: 1.28
        chevronHoverScale: 1.28
        label: "Bluetooth"
        active: root.btOn
        expanded: root.expanded
        onToggled: Backend.BluetoothService.toggle()
        onExpandClicked: root.expanded = !root.expanded
    }
}
