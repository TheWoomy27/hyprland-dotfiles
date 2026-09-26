pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wifiDevices: devices.filter(function(device) {
        return device.type === DeviceType.Wifi;
    })
    readonly property var wiredDevices: devices.filter(function(device) {
        return device.type === DeviceType.Wired;
    })
    readonly property var wifiDevice: wifiDevices.find(function(device) {
        return device.connected;
    }) || wifiDevices[0] || null
    readonly property var wiredDevice: wiredDevices.find(function(device) {
        return device.connected;
    }) || wiredDevices[0] || null
    readonly property var networks: wifiDevice ? wifiDevice.networks.values : []
    readonly property var networkRows: networks.map(function(network) {
        return {
            "network": network,
            "ssid": network.name,
            "signal": Math.round(network.signalStrength * 100),
            "secured": network.security !== WifiSecurityType.Open,
            "active": network.connected
        };
    }).sort(function(left, right) {
        if (left.active !== right.active)
            return left.active ? -1 : 1;
        return right.signal - left.signal;
    })
    readonly property var activeWifiNetwork: networks.find(function(network) {
        return network.connected;
    }) || null
    readonly property bool wifiConnected: !!(wifiDevice && wifiDevice.connected && activeWifiNetwork)
    readonly property bool wiredConnected: !!(wiredDevice && wiredDevice.connected)
    readonly property string connectionType: wifiConnected ? "wifi" : (wiredConnected ? "ethernet" : "none")
    readonly property string connType: connectionType
    readonly property string ssid: activeWifiNetwork ? activeWifiNetwork.name : ""
    readonly property int signalPercent: activeWifiNetwork
        ? Math.round(activeWifiNetwork.signalStrength * 100) : 0
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiAvailable: Networking.backend !== NetworkBackendType.None
        && wifiDevice !== null && Networking.wifiHardwareEnabled

    property int scannerClients: 0

    function toggleWifi() {
        if (Networking.wifiHardwareEnabled)
            Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function acquireScanner() {
        scannerClients += 1;
    }

    function releaseScanner() {
        scannerClients = Math.max(0, scannerClients - 1);
    }

    function connect(network) {
        if (network && !network.connected)
            network.connect();
    }

    function setAirplaneMode(enabled) {
        if (Networking.wifiHardwareEnabled)
            Networking.wifiEnabled = !enabled;
    }

    function applyScannerState() {
        if (wifiDevice)
            wifiDevice.scannerEnabled = scannerClients > 0 && Networking.wifiEnabled;
    }

    onScannerClientsChanged: applyScannerState()
    onWifiDeviceChanged: applyScannerState()
    Connections {
        target: Networking
        function onWifiEnabledChanged() { root.applyScannerState(); }
    }
}
