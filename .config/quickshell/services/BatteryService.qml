pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool available: !!(battery && battery.ready && battery.isPresent
        && (battery.isLaptopBattery || battery.type === UPowerDeviceType.Battery))
    readonly property int percent: available ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: available && (battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.PendingCharge)
    readonly property bool onBattery: UPower.onBattery
    readonly property real secondsRemaining: !available ? 0
        : (onBattery ? battery.timeToEmpty : battery.timeToFull)
}
