pragma Singleton

import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property var connectedDevices: available
        ? adapter.devices.values.filter(function(device) { return device.connected; })
        : []
    readonly property var connectedRows: connectedDevices.map(function(device) {
        return {
            "device": device,
            "mac": device.address,
            "name": device.name || device.deviceName || device.address,
            "battery": device.batteryAvailable ? String(Math.round(device.battery * 100)) : ""
        };
    })

    function setEnabled(value) {
        if (available)
            adapter.enabled = value;
    }

    function toggle() {
        setEnabled(!enabled);
    }

    function disconnect(device) {
        if (device && device.connected)
            device.disconnect();
    }
}
