// modules/Clock.qml
// Clock icon: 󰥔 (nf-md-clock_outline  U+F0154)
// Date icon:   (nf-md-calendar_month  U+F01D1 → but using  nf-md-calendar)
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
            text: "\udb81\udd54"
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
            text: "\udb80\uddbf"
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
