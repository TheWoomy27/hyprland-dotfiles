// shell.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.bezel
import "."

ShellRoot {
    id: shell

    property bool jarvisModeNotificationsEnabled: false

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

            property var panelLoader: LazyLoader {
                activeAsync: delegate.panelOpen

                ControlPanel {
                    screen: delegate.modelData
                    open: true
                    onDismissRequested: delegate.panelOpen = false
                }
            }

            property var jarvisDashboardLoader: LazyLoader {
                activeAsync: delegate.jarvisOpen

                JarvisDashboard {
                    screen: delegate.modelData
                    open: true
                    onDismissRequested: delegate.jarvisOpen = false
                }
            }

            property var jarvisCallOverlayLoader: LazyLoader {
                active: shell.jarvisModeNotificationsEnabled

                JarvisCallOverlay {
                    screen: delegate.modelData
                    modeNotificationsEnabled: true
                }
            }

            property var screenCorners: ScreenCorners {
                modelData: delegate.modelData
            }

        }
    }
}
