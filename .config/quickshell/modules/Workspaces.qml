// modules/Workspaces.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

BarItem {
    id: root
    hoverable: false

    property var    screen:     null
    property string screenName: screen ? (screen.name ?? "") : ""
    property bool   useMoonIndicator: true
    property var    workspaceIcons: ({})
    property var    nerdFontIcons: []
    property int    pickerWorkspaceId: -1
    property bool   pickerOpen: false
    property string iconSearch: ""

    onIconSearchChanged: iconModelSyncTimer.restart()
    onNerdFontIconsChanged: iconModelSyncTimer.restart()

    Component.onCompleted: iconModelSyncTimer.restart()

    property var baseIds:  screenName === "DP-5" ? [11, 12, 13, 14, 15] : [1, 2, 3, 4, 5]
    property var extraIds: screenName === "DP-5" ? [16, 17, 18, 19] : [6, 7, 8, 9]
    property var allIds:   baseIds.concat(extraIds)
    readonly property var defaultIconChoices: [
        { name: "clear remove none", icon: "" },
        { name: "terminal shell cli", icon: "\uf120" },
        { name: "code development programming", icon: "\uf121" },
        { name: "browser chrome web", icon: "\uf268" },
        { name: "firefox browser web", icon: "\uf269" },
        { name: "folder files projects", icon: "\uf07b" },
        { name: "file document notes", icon: "\uf15b" },
        { name: "book reading docs", icon: "\uf02d" },
        { name: "music audio spotify", icon: "\uf001" },
        { name: "video media", icon: "\uf03d" },
        { name: "image photos art", icon: "\uf03e" },
        { name: "camera capture", icon: "\uf030" },
        { name: "game gaming", icon: "\uf11b" },
        { name: "chat messages", icon: "\uf086" },
        { name: "mail email", icon: "\uf0e0" },
        { name: "settings config gear", icon: "\uf013" },
        { name: "monitor desktop", icon: "\uf108" },
        { name: "database server", icon: "\uf1c0" },
        { name: "cpu system monitor", icon: "\uf2db" },
        { name: "git branch repo", icon: "\uf126" },
        { name: "download", icon: "\uf019" },
        { name: "upload", icon: "\uf093" },
        { name: "archive package", icon: "\uf1c6" },
        { name: "chart analytics", icon: "\uf201" },
        { name: "cart shopping", icon: "\uf07a" },
        { name: "lock secure", icon: "\uf023" },
        { name: "bell notifications", icon: "\uf0f3" },
        { name: "home", icon: "\uf015" },
        { name: "rocket launch", icon: "\uf135" },
        { name: "globe network", icon: "\uf0ac" },
        { name: "bolt performance power", icon: "\uf0e7" },
        { name: "leaf power saver", icon: "\uf06c" },
        { name: "moon night", icon: "\uf186" },
        { name: "sun day", icon: "\uf185" },
        { name: "microphone audio input", icon: "\uf130" },
        { name: "headset headphones", icon: "󰋎" },
        { name: "speaker microphone", icon: "󰓃" },
        { name: "paint brush design", icon: "\uf1fc" },
        { name: "cube container", icon: "\uf1b2" },
        { name: "steam games", icon: "\uf1b6" },
        { name: "spotify music", icon: "\uf1bc" }
    ]
    readonly property var filteredIconChoices: {
        var q = iconSearch.trim().toLowerCase()
        if (q === "") return defaultIconChoices
        if (q.length < 2) return [{ name: "clear remove none", label: "Clear", pack: "Workspace", icon: "" }]

        var result = []
        for (var d = 0; d < defaultIconChoices.length && result.length < 96; d++) {
            var def = defaultIconChoices[d]
            if (def.name.indexOf(q) !== -1 || def.icon.indexOf(q) !== -1)
                result.push(def)
        }

        for (var i = 0; i < nerdFontIcons.length && result.length < 96; i++) {
            var item = nerdFontIcons[i]
            if (item.name.indexOf(q) !== -1 || item.icon.indexOf(q) !== -1)
                result.push(item)
        }
        return result
    }
    readonly property int activeWsId: Hyprland.focusedWorkspace !== null
                                      && Hyprland.focusedWorkspace !== undefined
                                      ? Hyprland.focusedWorkspace.id : -1
    readonly property int activeVisibleIndex: visibleIds.indexOf(activeWsId)
    readonly property int moonSize: 40
    readonly property real moonTargetX: {
        var item = wsRep.itemAt(activeVisibleIndex)
        if (!item) return 8
        return wsRow.x + item.x + (item.width - moonSize) / 2
    }

    FileView {
        id: iconFile
        path: "/home/austin/.config/quickshell/workspace-icons.json"
        preload: true
        blockLoading: true
        watchChanges: true
        printErrors: false

        JsonAdapter {
            id: iconStore
            property var icons: ({})
        }

        onLoaded: root.workspaceIcons = iconStore.icons || ({})
        onAdapterUpdated: root.workspaceIcons = iconStore.icons || ({})
        onLoadFailed: root.workspaceIcons = ({})
    }

    FileView {
        id: nerdFontFile
        path: "/home/austin/.config/quickshell/nerd-font-icons.json"
        preload: true
        blockLoading: true
        printErrors: false

        JsonAdapter {
            id: nerdFontStore
            property var icons: []
        }

        onLoaded: root.nerdFontIcons = nerdFontStore.icons || []
        onAdapterUpdated: root.nerdFontIcons = nerdFontStore.icons || []
        onLoadFailed: root.nerdFontIcons = []
    }

    function workspaceIcon(wsId) {
        var icon = workspaceIcons[wsId.toString()]
        return icon === undefined || icon === null ? "" : icon
    }

    function setWorkspaceIcon(wsId, icon) {
        var key = wsId.toString()
        var next = {}
        for (var k in workspaceIcons)
            next[k] = workspaceIcons[k]

        if (icon === "")
            delete next[key]
        else
            next[key] = icon

        workspaceIcons = next
        iconStore.icons = next
        iconFile.writeAdapter()
        pickerOpen = false
    }

    function openIconPicker(wsId) {
        pickerWorkspaceId = wsId
        iconSearch = ""
        syncIconModel()
        pickerOpen = true
        focusSearchTimer.restart()
    }

    function iconChoiceKey(item) {
        if (item.id !== undefined && item.id !== null && item.id !== "")
            return item.id
        return "default:" + (item.name || "") + ":" + (item.icon || "")
    }

    function iconChoiceEntry(item) {
        return {
            key: iconChoiceKey(item),
            name: item.name || "",
            label: item.label || "",
            pack: item.pack || "",
            iconId: item.id || "",
            icon: item.icon || ""
        }
    }

    function iconModelIndex(key) {
        for (var i = 0; i < iconListModel.count; i++) {
            if (iconListModel.get(i).key === key)
                return i
        }
        return -1
    }

    function syncIconModel() {
        var next = filteredIconChoices
        var keep = {}
        for (var i = 0; i < next.length; i++)
            keep[iconChoiceKey(next[i])] = true

        for (var r = iconListModel.count - 1; r >= 0; r--) {
            if (!keep[iconListModel.get(r).key])
                iconListModel.remove(r)
        }

        for (var n = 0; n < next.length; n++) {
            var entry = iconChoiceEntry(next[n])
            var current = iconModelIndex(entry.key)

            if (current === -1) {
                iconListModel.insert(n, entry)
            } else {
                if (current !== n)
                    iconListModel.move(current, n, 1)
                iconListModel.set(n, entry)
            }
        }
    }

    function paintRoundedGradient(ctx, w, h, r, t) {
        ctx.clearRect(0, 0, w, h)
        var cx = w / 2
        var cy = h / 2
        var len = Math.sqrt(w * w + h * h) / 2
        var angle = (Math.PI / 4) + t * Math.PI
        var dx = Math.cos(angle) * len
        var dy = Math.sin(angle) * len
        var grad = ctx.createLinearGradient(cx - dx, cy - dy, cx + dx, cy + dy)
        grad.addColorStop(0.0, "#7cafff")
        grad.addColorStop(1.0, "#3b63cf")
        ctx.fillStyle = grad
        ctx.beginPath()
        ctx.moveTo(r, 0)
        ctx.arcTo(w, 0, w, h, r)
        ctx.arcTo(w, h, 0, h, r)
        ctx.arcTo(0, h, 0, 0, r)
        ctx.arcTo(0, 0, w, 0, r)
        ctx.closePath()
        ctx.fill()
    }

    ListModel {
        id: iconListModel
    }

    Timer {
        id: iconModelSyncTimer
        interval: 0
        onTriggered: root.syncIconModel()
    }

    Timer {
        id: focusSearchTimer
        interval: 40
        onTriggered: searchInput.forceActiveFocus()
    }

    // Count windows per workspace directly from toplevels — fully reactive,
    // updates whenever any window opens, closes, or moves.
    readonly property var occupiedMap: {
        var occ = {}
        var tls = Hyprland.toplevels.values
        for (var i = 0; i < tls.length; i++) {
            var ws = tls[i].workspace
            if (ws !== null && ws !== undefined)
                occ[ws.id] = true
        }
        return occ
    }

    property var visibleIds: {
        var occ    = root.occupiedMap
        var fw     = Hyprland.focusedWorkspace
        var result = root.baseIds.slice()
        var extra  = root.extraIds

        for (var i = 0; i < extra.length; i++) {
            var eid = extra[i]
            if (occ[eid] && result.indexOf(eid) === -1)
                result.push(eid)
        }

        if (fw !== null && fw !== undefined) {
            var fid = fw.id
            if (root.allIds.indexOf(fid) !== -1 && result.indexOf(fid) === -1)
                result.push(fid)
        }

        result.sort(function(a, b) { return a - b })
        return result
    }

    // Animate module width when extra workspaces appear/disappear
    implicitWidth: wsRow.implicitWidth + 16
    Behavior on implicitWidth {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    Image {
        id: moonIndicator
        visible: root.useMoonIndicator && root.activeVisibleIndex >= 0
        source: "moon.png"
        width: root.moonSize
        height: root.moonSize
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        x: root.moonTargetX
        y: (root.height - height) / 2 - 2
        z: 1

        Behavior on x {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
    }

    RowLayout {
        id: wsRow
        z: 2
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            id: wsRep
            model: root.visibleIds
            delegate: WsButton {
                required property var modelData
                wsId:       modelData
                isBase:     root.baseIds.indexOf(modelData) !== -1
                isOccupied: root.occupiedMap[modelData] ?? false
                isActive:   Hyprland.focusedWorkspace !== null
                            && Hyprland.focusedWorkspace !== undefined
                            && Hyprland.focusedWorkspace.id === modelData
            }
        }
    }

    PanelWindow {
        id: pickerWindow
        screen: root.screen
        visible: root.pickerOpen
        anchors { top: true; left: true; right: true }
        margins { top: 20; left: 20; right: 20 }
        implicitHeight: 410
        exclusiveZone: 0
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        focusable: true
        aboveWindows: true

        MouseArea {
            anchors.fill: parent
            onClicked: root.pickerOpen = false
        }

        Canvas {
            id: pickerBorder
            width: 420
            height: 398
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            antialiasing: true
            onPaint: {
                var ctx = getContext("2d")
                root.paintRoundedGradient(ctx, width, height, 16, 0.0)
            }
        }

        Rectangle {
            id: pickerPanel
            anchors { fill: pickerBorder; margins: 3 }
            radius: 13
            color: "#131421"
            clip: true

            Column {
                anchors { fill: parent; margins: 12 }
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 78
                    radius: 12
                    color: "#191a2a"

                    Column {
                        anchors { fill: parent; margins: 8 }
                        spacing: 7

                        RowLayout {
                            width: parent.width
                            spacing: 10

                            Text {
                                text: "Workspace " + root.pickerWorkspaceId
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 13
                                font.weight: Font.ExtraBold
                                color: "#cdd9ff"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Type 2+ chars to search " + root.nerdFontIcons.length + " icons"
                                horizontalAlignment: Text.AlignRight
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: "#596285"
                            }
                        }

                        Rectangle {
                            width: parent.width - 8
                            height: 36
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 10
                            color: "#1e2030"
                            border.width: 1
                            border.color: "#2f3f68"

                            Text {
                                anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                                text: "\uf002"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 12
                                font.weight: Font.ExtraBold
                                color: "#7cafff"
                            }

                            TextInput {
                                id: searchInput
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 34
                                    rightMargin: 12
                                }
                                text: root.iconSearch
                                onTextChanged: root.iconSearch = text
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: "#e7efff"
                                selectionColor: "#3b63cf"
                                selectedTextColor: "#ffffff"
                                clip: true
                                Keys.onEscapePressed: root.pickerOpen = false
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 230
                    radius: 12
                    color: "#131421"
                    clip: true

                    GridView {
                        id: iconGrid
                        anchors.fill: parent
                        clip: true
                        cellWidth: 65
                        cellHeight: 65
                        model: iconListModel

                        remove: Transition {
                            ParallelAnimation {
                                NumberAnimation { properties: "opacity"; to: 0.0; duration: 150; easing.type: Easing.InCubic }
                                NumberAnimation { properties: "scale"; to: 0.62; duration: 190; easing.type: Easing.InCubic }
                            }
                        }

                        displaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 420; easing.type: Easing.OutCubic }
                        }

                        moveDisplaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 420; easing.type: Easing.OutCubic }
                        }

                        removeDisplaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 440; easing.type: Easing.OutCubic }
                        }

                        addDisplaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 440; easing.type: Easing.OutCubic }
                        }

                        delegate: Item {
                            id: iconCell
                            required property string name
                            required property string label
                            required property string pack
                            required property string iconId
                            required property string icon
                            width: iconGrid.cellWidth
                            height: iconGrid.cellHeight
                            property bool hov: iconMouse.containsMouse
                            readonly property bool selected: root.workspaceIcon(root.pickerWorkspaceId) === iconCell.icon
                            property real gradientT: 0.0
                            opacity: 0.0
                            scale: 0.65

                            Component.onCompleted: enterAnim.start()

                            onHovChanged: {
                                gradientAnim.stop()
                                gradientAnim.from = gradientT
                                gradientAnim.to = hov ? 1.0 : 0.0
                                gradientAnim.start()
                            }

                            onGradientTChanged: {
                                cellBorder.requestPaint()
                                cellFill.requestPaint()
                            }

                            NumberAnimation {
                                id: gradientAnim
                                target: iconCell
                                property: "gradientT"
                                duration: 400
                                easing.type: Easing.InOutCubic
                            }

                            SequentialAnimation {
                                id: enterAnim
                                PauseAnimation { duration: Math.min(220, index * 12) }
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: iconCell
                                        property: "opacity"
                                        from: 0.0
                                        to: 1.0
                                        duration: 180
                                        easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation {
                                        target: iconCell
                                        property: "scale"
                                        from: 0.65
                                        to: 1.0
                                        duration: 520
                                        easing.type: Easing.OutBack
                                    }
                                }
                            }

                            Canvas {
                                id: cellBorder
                                anchors { fill: parent; margins: 4 }
                                antialiasing: true
                                onPaint: {
                                    var ctx = getContext("2d")
                                    root.paintRoundedGradient(ctx, width, height, 10, iconCell.gradientT)
                                }
                                onWidthChanged: requestPaint()
                                onHeightChanged: requestPaint()
                            }

                            Rectangle {
                                anchors { fill: parent; margins: 7 }
                                radius: 8
                                color: iconCell.hov && !iconCell.selected ? "#2a2d47" : "#1e2030"
                                visible: !iconCell.selected
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            Canvas {
                                id: cellFill
                                anchors { fill: parent; margins: 7 }
                                antialiasing: true
                                opacity: iconCell.selected ? 1.0 : 0.0
                                onPaint: {
                                    var ctx = getContext("2d")
                                    root.paintRoundedGradient(ctx, width, height, 8, iconCell.gradientT)
                                }
                                onWidthChanged: requestPaint()
                                onHeightChanged: requestPaint()
                                Behavior on opacity {
                                    NumberAnimation { duration: 220; easing.type: Easing.InOutCubic }
                                }
                            }

                            Text {
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    top: parent.top
                                    topMargin: 10
                                }
                                text: iconCell.icon === "" ? "\uf00d" : iconCell.icon
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: iconCell.icon === "󰓃" ? 15 : 20
                                font.weight: Font.ExtraBold
                                color: iconCell.selected ? "#191a2a" : (iconCell.icon === "" ? "#ff6b6b" : "#7cafff")
                                scale: iconCell.hov ? 1.22 : 1.0
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Behavior on scale {
                                    NumberAnimation { duration: 600; easing.type: Easing.OutBack }
                                }
                            }

                            Text {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                    leftMargin: 7
                                    rightMargin: 7
                                    bottomMargin: 8
                                }
                                text: iconCell.label || iconCell.name.split(" ")[0]
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: iconCell.selected ? "#191a2a" : "#8d98c5"
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            MouseArea {
                                id: iconMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setWorkspaceIcon(root.pickerWorkspaceId, iconCell.icon)
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 42
                    radius: 12
                    color: "#191a2a"

                    RowLayout {
                        anchors { fill: parent; margins: 7 }
                        spacing: 8

                        Text {
                            text: "Paste custom glyph:"
                            font.family: "JetBrainsMono Nerd Font Propo"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: "#596285"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: "#1e2030"
                            border.width: 1
                            border.color: "#2f3f68"

                            TextInput {
                                id: customIconInput
                                anchors {
                                    fill: parent
                                    leftMargin: 10
                                    rightMargin: 10
                                }
                                verticalAlignment: Text.AlignVCenter
                                text: ""
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 14
                                font.weight: Font.ExtraBold
                                color: "#e7efff"
                                selectionColor: "#3b63cf"
                                selectedTextColor: "#ffffff"
                                clip: true
                                Keys.onEscapePressed: root.pickerOpen = false
                            }
                        }

                        Rectangle {
                            width: 78
                            Layout.fillHeight: true
                            radius: 8
                            color: customUseArea.containsMouse ? "#2a3456" : "#1e2030"
                            border.width: 1
                            border.color: "#7cafff"

                            Text {
                                anchors.centerIn: parent
                                text: "Use"
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 12
                                font.weight: Font.ExtraBold
                                color: "#7cafff"
                            }

                            MouseArea {
                                id: customUseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (customIconInput.text.trim() !== "")
                                    root.setWorkspaceIcon(root.pickerWorkspaceId, customIconInput.text.trim())
                            }
                        }
                    }
                }
            }
        }
    }

    component WsButton: Item {
        id: btn

        property int  wsId:       1
        property bool isBase:     true
        property bool isOccupied: false
        property bool isActive:   false

        readonly property bool hov: btnArea.containsMouse
        readonly property string assignedIcon: root.workspaceIcon(btn.wsId)
        readonly property bool hasIcon: assignedIcon !== ""
        readonly property color contentColor: btn.isActive
                                        ? "#191a2a"
                                        : btn.isOccupied ? "#7cafff" : "#3a4f6a"

        // Both active and inactive use the same animation duration/easing
        // so the total module width stays constant during workspace switching.
        implicitWidth:  isActive ? 40 : 28
        implicitHeight: 28
        opacity:        (isBase && !isActive && !isOccupied) ? 0.30 : 1.0

        Behavior on implicitWidth {
            NumberAnimation { duration: 220; easing.type: Easing.InOutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        // Hover highlight — uniform for all non-active buttons
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color:  (btn.hov && !btn.isActive) ? "#7cafff" : "transparent"
            opacity: 0.12
            z: 0
            Behavior on color   { ColorAnimation { duration: 120 } }
        }

        // Active gradient fill — opacity-animated so it fades in/out
        Canvas {
            id: activeCanvas
            anchors.fill: parent
            antialiasing: true
            // Always rendered, fades in/out — this creates the smooth transition
            opacity: (!root.useMoonIndicator && btn.isActive) ? 1.0 : 0.0
            visible: opacity > 0
            z: 1

            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.InOutCubic }
            }

            onPaint: {
                var ctx  = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var r    = height / 2
                var grad = ctx.createLinearGradient(0, 0, width, 0)
                grad.addColorStop(0.0, "#7cafff")
                grad.addColorStop(1.0, "#3b63cf")
                ctx.fillStyle = grad
                ctx.beginPath()
                ctx.moveTo(r, 0)
                ctx.arcTo(width, 0,      width, height, r)
                ctx.arcTo(width, height, 0,     height, r)
                ctx.arcTo(0,     height, 0,     0,      r)
                ctx.arcTo(0,     0,      width, 0,      r)
                ctx.closePath()
                ctx.fill()
            }

            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()
        }

        // Base background — same colour regardless of occupied/empty
        // Occupied distinction is via text colour only
        Rectangle {
            visible: !root.useMoonIndicator && !btn.isActive
            anchors.fill: parent
            radius: height / 2
            color: "#191a2a"
            z: 0
        }

        // Icon assignment. The workspace number becomes a small badge.
        Text {
            visible: btn.hasIcon
            anchors.centerIn: parent
            text: btn.assignedIcon
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: btn.assignedIcon === "󰓃" ? 13 : 17
            font.weight:    Font.ExtraBold
            color: btn.contentColor
            scale: (!btn.isActive && btn.hov) ? 1.35 : 1.0
            z: 3
            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
        }

        Text {
            visible: btn.hasIcon
            anchors {
                right: parent.right
                bottom: parent.bottom
                rightMargin: 4
                bottomMargin: 2
            }
            text: btn.wsId.toString()
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: btn.wsId >= 10 ? 7 : 8
            font.weight: Font.ExtraBold
            color: btn.contentColor
            opacity: 0.80
            z: 4
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        // Plain number fallback.
        Text {
            visible: !btn.hasIcon
            anchors.centerIn: parent
            text: btn.wsId.toString()
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: btn.contentColor
            scale: (!btn.isActive && btn.hov) ? 1.5 : 1.0
            z: 3
            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            z: 4
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton)
                    root.openIconPicker(btn.wsId)
                else
                    switchWorkspace.running = true
            }
        }

        Process {
            id: switchWorkspace
            command: ["hyprctl", "dispatch", "hl.dsp.focus({ workspace = " + btn.wsId.toString() + " })"]
            running: false
        }
    }
}
