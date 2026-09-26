pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configDir: Quickshell.env("HOME") + "/.config/quickshell"
    readonly property string workspaceIconPath: configDir + "/workspace-icons.json"
    readonly property string nerdFontIconPath: configDir + "/nerd-font-icons.json"

    property var workspaceIcons: ({})
    property var nerdFontIcons: []
    property bool catalogRequested: false
    property bool catalogLoaded: false

    function requestCatalog() {
        catalogRequested = true
    }

    function setWorkspaceIcon(workspaceId, icon) {
        var key = workspaceId.toString()
        var next = {}
        var keys = Object.keys(workspaceIcons)
        for (var i = 0; i < keys.length; i++)
            next[keys[i]] = workspaceIcons[keys[i]]

        if (icon === "")
            delete next[key]
        else
            next[key] = icon

        workspaceIcons = next
        workspaceIconStore.icons = next
        workspaceIconFile.writeAdapter()
    }

    FileView {
        id: workspaceIconFile
        path: root.workspaceIconPath
        preload: true
        blockLoading: true
        watchChanges: true
        printErrors: false

        JsonAdapter {
            id: workspaceIconStore
            property var icons: ({})
        }

        onLoaded: root.workspaceIcons = workspaceIconStore.icons || ({})
        onAdapterUpdated: root.workspaceIcons = workspaceIconStore.icons || ({})
        onLoadFailed: root.workspaceIcons = ({})
    }

    FileView {
        path: root.nerdFontIconPath
        preload: root.catalogRequested
        blockLoading: false
        printErrors: false

        JsonAdapter {
            id: nerdFontIconStore
            property var icons: []
        }

        onLoaded: {
            root.nerdFontIcons = nerdFontIconStore.icons || []
            root.catalogLoaded = true
        }
        onAdapterUpdated: {
            root.nerdFontIcons = nerdFontIconStore.icons || []
            root.catalogLoaded = true
        }
        onLoadFailed: {
            root.nerdFontIcons = []
            root.catalogLoaded = true
        }
    }
}
