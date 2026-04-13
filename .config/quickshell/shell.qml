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

            property var bar: Bar {
                screen:    delegate.modelData
                panelOpen: delegate.panelOpen
                onTogglePanel: delegate.panelOpen = !delegate.panelOpen
            }

            property var panel: ControlPanel {
                screen: delegate.modelData
                open:   delegate.panelOpen
                onDismissRequested: delegate.panelOpen = false
            }
        }
    }
}
