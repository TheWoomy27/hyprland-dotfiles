// panel/ToggleGrid.qml
// Dropdowns escape the RowLayout and span full width below each header row.
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    implicitWidth:  parent ? parent.width : 380
    implicitHeight: mainCol.implicitHeight

    property bool panelOpen: true
    onPanelOpenChanged: {
        if (!panelOpen) {
            wifiEx.expanded  = false
            btEx.expanded    = false
            pmEx.expanded    = false
        }
    }

    property bool   nightLightOn:   false
    property bool   dndOn:          false
    property bool   airplaneOn:     false
    property bool   caffeineOn:     false
    property bool   animationsOn:   true
    property string nightLightTemp: "3500"
    property string inhibitPid:     ""

    Process { id: nlOn;  command: ["hyprsunset", "-t", root.nightLightTemp]; running: false }
    Process { id: nlOff; command: ["pkill", "hyprsunset"];                   running: false }
    Process {
        id: dndToggle; command: ["swaync-client", "--toggle-dnd"]; running: false
        onRunningChanged: if (!running) dndRead.running = true
    }
    Process {
        id: dndRead; command: ["swaync-client", "--get-dnd"]; running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(l) { root.dndOn = l.trim() === "true" }
        }
    }
    Process { id: apOn;  command: ["bash", "-c", "nmcli radio wifi off && bluetoothctl power off"]; running: false }
    Process { id: apOff; command: ["bash", "-c", "nmcli radio wifi on  && bluetoothctl power on"];  running: false }
    Process {
        id: animToggle
        command: ["bash", "-c", "hyprctl keyword animations:enabled " + (root.animationsOn ? "false" : "true")]
        running: false
        onRunningChanged: if (!running) root.animationsOn = !root.animationsOn
    }
    Process {
        id: cafOn
        command: ["bash", "-c",
            "systemd-inhibit --what=idle --who=Caffeine --why=UserRequest --mode=block sleep infinity & echo $!"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(l) { root.inhibitPid = l.trim(); root.caffeineOn = root.inhibitPid !== "" }
        }
    }
    Process {
        id: cafOff; command: ["bash", "-c", "kill " + root.inhibitPid]; running: false
        onRunningChanged: if (!running) { root.caffeineOn = false; root.inhibitPid = "" }
    }

    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: dndRead.running = true }

    Column {
        id: mainCol
        width: parent.width
        spacing: 8

        // ── Row 1: Wifi | Bluetooth ─────────────────────────────────────
        Column {
            width: parent.width
            spacing: 0

            RowLayout {
                width: parent.width; spacing: 8
                WifiExpander      { id: wifiEx; Layout.fillWidth: true }
                BluetoothExpander { id: btEx;   Layout.fillWidth: true }
            }

            // Full-width dropdown below both headers
            Item {
                width:  parent.width
                height: (wifiEx.expanded || btEx.expanded) ? dropdownBox1.implicitHeight + 10 : 0
                clip:   true
                Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                Rectangle {
                    id: dropdownBox1
                    anchors { top: parent.top; topMargin: 8; left: parent.left; right: parent.right }
                    color: "#1e2030"; radius: 12; clip: true
                    implicitHeight: dd1inner.implicitHeight + 8

                    Column {
                        id: dd1inner
                        width: parent.width
                        topPadding: 4; bottomPadding: 4; spacing: 0

                        // Wifi network list
                        Repeater {
                            model: wifiEx.expanded ? wifiEx.networks : []
                            delegate: NetRow {
                                required property var modelData
                                netSsid:  modelData.ssid
                                signal_:  modelData.signal
                                secured:  modelData.secured
                                isActive: modelData.active
                                width:    dd1inner.width
                                onConnectRequested: wifiEx.scan()
                            }
                        }

                        // Bluetooth device list
                        Text {
                            visible: btEx.expanded && btEx.devices.length === 0
                            width: parent.width; height: 36
                            text: "No connected devices"
                            leftPadding: 14
                            font.family: "JetBrainsMono Nerd Font Propo"
                            font.pixelSize: 12; color: "#444a73"
                            verticalAlignment: Text.AlignVCenter
                        }
                        Repeater {
                            model: btEx.expanded ? btEx.devices : []
                            delegate: BtRow {
                                required property var modelData
                                devMac:  modelData.mac
                                devName: modelData.name
                                devBat:  modelData.battery
                                width:   dd1inner.width
                            }
                        }
                    }
                }
            }
        }

        // ── Row 2: Power Mode | Night Light ─────────────────────────────
        Column {
            width: parent.width
            spacing: 0

            RowLayout {
                width: parent.width; spacing: 8
                PowerModeExpander { id: pmEx; Layout.fillWidth: true }
                Toggle {
                    Layout.fillWidth: true; implicitHeight: 48
                    icon: ""; label: "Night Light"; active: root.nightLightOn
                    onClicked: {
                        root.nightLightOn = !root.nightLightOn
                        if (root.nightLightOn) nlOn.running = true; else nlOff.running = true
                    }
                }
            }

            // Full-width power mode dropdown
            Item {
                width:  parent.width
                height: pmEx.expanded ? dropdownBox2.implicitHeight + 10 : 0
                clip:   true
                Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                Rectangle {
                    id: dropdownBox2
                    anchors { top: parent.top; topMargin: 8; left: parent.left; right: parent.right }
                    color: "#1e2030"; radius: 12; clip: true
                    implicitHeight: dd2inner.implicitHeight + 8

                    Column {
                        id: dd2inner
                        width: parent.width
                        topPadding: 4; bottomPadding: 4; spacing: 0

                        Repeater {
                            model: pmEx.profiles
                            delegate: ProfRow {
                                required property var modelData
                                profId:    modelData.id
                                profLabel: modelData.label
                                profIcon:  modelData.icon
                                isActive:  pmEx.activeProfile === modelData.id
                                width:     dd2inner.width
                                onSelected: pmEx.setProfile(modelData.id)
                            }
                        }
                    }
                }
            }
        }

        // ── Row 3: DND | Airplane ────────────────────────────────────────
        RowLayout {
            width: parent.width; spacing: 8
            Toggle {
                Layout.fillWidth: true; implicitHeight: 48
                icon: "󰍶"
                label: "Do Not Disturb"; active: root.dndOn
                onClicked: dndToggle.running = true
            }
            Toggle {
                Layout.fillWidth: true; implicitHeight: 48
                icon: "\uf072"; label: "Airplane Mode"; active: root.airplaneOn
                onClicked: {
                    root.airplaneOn = !root.airplaneOn
                    if (root.airplaneOn) apOn.running = true; else apOff.running = true
                }
            }
        }

        // ── Row 4: Caffeine | Animations ─────────────────────────────────
        RowLayout {
            width: parent.width; spacing: 8
            Toggle {
                Layout.fillWidth: true; implicitHeight: 48
                icon: "󰅶"
                label: "Caffeine"; active: root.caffeineOn
                onClicked: { if (!root.caffeineOn) cafOn.running = true; else cafOff.running = true }
            }
            Toggle {
                Layout.fillWidth: true; implicitHeight: 48
                icon: "󰗘"
                label: "Animations"; active: root.animationsOn
                onClicked: animToggle.running = true
            }
        }
    }

    // ── Shared dropdown row components ────────────────────────────────────

    component NetRow: Item {
        property string netSsid:  ""
        property int    signal_:  0
        property bool   secured:  false
        property bool   isActive: false
        signal connectRequested()
        implicitHeight: 36
        property bool hov: nh.containsMouse

        Rectangle {
            anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
            radius: 8
            color: isActive ? "#2f334d" : "transparent"
            Rectangle {
                anchors.fill: parent; radius: parent.radius; color: "#222436"
                opacity: (hov && !isActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Row {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                spacing: 8
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf1eb"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 12; font.weight: Font.ExtraBold
                    color: isActive ? "#7cafff" : "#828bb8"
                    opacity: signal_ >= 70 ? 1.0 : signal_ >= 40 ? 0.65 : 0.35
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: netSsid
                    width: parent.width - 50
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 12; font.weight: Font.Bold
                    color: isActive ? "#7cafff" : "#828bb8"
                    elide: Text.ElideRight
                }
            }
        }

        Process { id: connProc; command: ["nmcli","device","wifi","connect",netSsid]; running: false
                  onRunningChanged: if (!running) connectRequested() }

        MouseArea {
            id: nh; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (!isActive) connProc.running = true
        }
    }

    component BtRow: Item {
        property string devMac:  ""
        property string devName: ""
        property string devBat:  ""
        implicitHeight: 36
        property bool hov: bh.containsMouse

        Rectangle {
            anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
            radius: 8; color: "transparent"
            Rectangle {
                anchors.fill: parent; radius: parent.radius; color: "#222436"
                opacity: hov ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
            Row {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                spacing: 8
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf293"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 13; font.weight: Font.ExtraBold; color: "#7cafff"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: devName
                    width: parent.width - (devBat !== "" ? 70 : 40)
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 12; font.weight: Font.Bold
                    color: "#828bb8"; elide: Text.ElideRight
                }
                Text {
                    visible: devBat !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: devBat + "%"
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 11; color: "#828bb8"
                }
            }
        }

        Process { id: disconnProc; command: ["bluetoothctl","disconnect",devMac]; running: false }
        MouseArea {
            id: bh; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: disconnProc.running = true
        }
    }

    component ProfRow: Item {
        property string profId:    ""
        property string profLabel: ""
        property string profIcon:  ""
        property bool   isActive:  false
        signal selected()
        implicitHeight: 38
        property bool hov: peh.containsMouse

        Rectangle {
            anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
            radius: 8
            color: isActive ? "#2f334d" : "transparent"
            Rectangle {
                anchors.fill: parent; radius: parent.radius; color: "#222436"
                opacity: (hov && !isActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
            Row {
                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                spacing: 10
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: profIcon
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 14; font.weight: Font.ExtraBold
                    color: isActive ? "#7cafff" : "#828bb8"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: profLabel
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 13; font.weight: Font.Bold
                    color: isActive ? "#7cafff" : "#828bb8"
                }
            }
        }

        MouseArea {
            id: peh; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (!isActive) parent.selected()
        }
    }
}
