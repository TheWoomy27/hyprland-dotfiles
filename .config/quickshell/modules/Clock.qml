// modules/Clock.qml
// Time icon: \udb82\udd54  Calendar icon: \uf073
import QtQuick
import QtQuick.Layouts

BarItem {
    id: root
    implicitWidth: crow.implicitWidth + 20

    property string timeStr: Qt.formatTime(new Date(), "h:mm:ss AP")
    property string dateStr: Qt.formatDate(new Date(), "ddd, MMM d")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var d    = new Date()
            root.timeStr = Qt.formatTime(d, "h:mm:ss AP")
            root.dateStr = Qt.formatDate(d, "ddd, MMM d")
        }
    }

    RowLayout {
        id: crow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "\udb82\udd54"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
        Text {
            text: root.timeStr
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }

        Text {
            text: "·"
            font.pixelSize: 12
            color: "#2a3a52"
        }

        Text {
            text: "\uf073"
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
        Text {
            text: root.dateStr
            font.family:    "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.weight:    Font.ExtraBold
            color: "#7cafff"
        }
    }
}
