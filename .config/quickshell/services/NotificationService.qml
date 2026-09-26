pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property bool dnd: state.dnd
    readonly property var notifications: server.trackedNotifications.values
    readonly property int unreadCount: notifications.length

    function toggleDnd() {
        state.dnd = !state.dnd
    }

    function clear() {
        const current = notifications.slice()
        for (const notification of current)
            notification.dismiss()
    }

    PersistentProperties {
        id: state
        reloadableId: "moonlight-notifications"
        property bool dnd: false
    }

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: false
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        inlineReplySupported: false

        onNotification: notification => {
            notification.tracked = true
        }
    }
}
