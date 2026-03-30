// shell.qml — Quickshell entry point
import Quickshell
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: QtObject {
            required property var modelData
            property var bar: Bar { screen: modelData }
        }
    }
}
