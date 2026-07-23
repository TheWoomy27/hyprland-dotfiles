// shell.qml
import Quickshell
import QtQuick
import "."

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: QtObject {
            id: delegate
            required property var modelData

            property bool panelOpen: false
            property bool jarvisOpen: false

            property var bar: Bar {
                screen:    delegate.modelData
                panelOpen: delegate.panelOpen
                onTogglePanel: delegate.panelOpen = !delegate.panelOpen
                onToggleJarvisDashboard: delegate.jarvisOpen = !delegate.jarvisOpen
            }

            property var panel: ControlPanel {
                screen: delegate.modelData
                open:   delegate.panelOpen
                onDismissRequested: delegate.panelOpen = false
            }

            property var jarvisDashboard: JarvisDashboard {
                screen: delegate.modelData
                open:   delegate.jarvisOpen
                onDismissRequested: delegate.jarvisOpen = false
            }

            property var jarvisCallOverlay: JarvisCallOverlay {
                screen: delegate.modelData
            }
        }
    }
}
