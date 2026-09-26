// modules/Audio.qml
// Native PipeWire state; left click mutes, right click opens pavucontrol.
import QtQuick
import QtQuick.Layouts
import "../services" as Backend

BarItem {
    id: root
    implicitWidth: arow.implicitWidth + 20

    readonly property real volume: Backend.AudioService.volume
    readonly property bool muted: Backend.AudioService.muted
    readonly property int volPct: Math.round(volume * 100)
    readonly property string sinkType: Backend.AudioService.sinkType
    readonly property string audioProfile: sinkType
    property string displayedProfileIcon: "󰓃"
    property int displayedProfileIconSize: 13
    property string profileSwapTargetProfile: "speaker"
    property string profileSwapTargetIcon: "󰓃"
    property int profileSwapTargetIconSize: 13
    property real profileSwapScale: 1.0
    readonly property int volumeLabelWidth: 30

    function volIcon() {
        if (muted || volPct === 0)
            return sinkType === "headset" ? "󰁺" : "\uf026";
        if (sinkType === "headset")
            return "󰁺";
        if (volPct < 50)
            return "\uf027";
        return "\uf028";
    }

    function profileIconFor(profile) {
        return profile === "headset" ? "󰋎" : "󰓃";
    }

    function profileIconSizeFor(profile) {
        return profile === "headset" ? 16 : 13;
    }

    function swapProfileIcon(profile) {
        if (profileSwapAnim.running && profileSwapTargetProfile === profile)
            return;

        profileSwapTargetProfile = profile;
        profileSwapTargetIcon = profileIconFor(profile);
        profileSwapTargetIconSize = profileIconSizeFor(profile);

        if (displayedProfileIcon === profileSwapTargetIcon
                && displayedProfileIconSize === profileSwapTargetIconSize)
            return;

        profileSwapAnim.restart();
    }

    function adjustVolume(up) {
        Backend.AudioService.adjustVolume(up ? 0.05 : -0.05);
    }

    onAudioProfileChanged: swapProfileIcon(audioProfile)

    Component.onCompleted: {
        displayedProfileIcon = profileIconFor(audioProfile);
        displayedProfileIconSize = profileIconSizeFor(audioProfile);
        profileSwapTargetProfile = audioProfile;
        profileSwapTargetIcon = displayedProfileIcon;
        profileSwapTargetIconSize = displayedProfileIconSize;
    }

    SequentialAnimation {
        id: profileSwapAnim
        NumberAnimation {
            target: root
            property: "profileSwapScale"
            to: 0.0
            duration: 170
            easing.type: Easing.InCubic
        }
        ScriptAction {
            script: {
                root.displayedProfileIcon = root.profileSwapTargetIcon;
                root.displayedProfileIconSize = root.profileSwapTargetIconSize;
            }
        }
        NumberAnimation {
            target: root
            property: "profileSwapScale"
            to: 1.0
            duration: 430
            easing.type: Easing.OutBack
        }
    }

    RowLayout {
        id: arow
        anchors.centerIn: parent
        spacing: 5

        Item {
            id: profileIconBox
            implicitWidth: 20
            implicitHeight: 24
            property real hoverScale: profileArea.containsMouse ? 1.5 : 1.2

            Behavior on hoverScale {
                NumberAnimation { duration: 600; easing.type: Easing.OutBack }
            }

            Text {
                anchors.centerIn: parent
                text: root.displayedProfileIcon
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: root.displayedProfileIconSize
                font.weight: Font.ExtraBold
                color: "#7cafff"
                scale: root.profileSwapScale * profileIconBox.hoverScale
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            MouseArea {
                id: profileArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: Backend.AudioService.cycleSink()
                onWheel: function(wheel) { root.adjustVolume(wheel.angleDelta.y > 0); }
            }
        }

        Item {
            implicitWidth: volRow.implicitWidth
            implicitHeight: 24

            RowLayout {
                id: volRow
                anchors.centerIn: parent
                spacing: 5

                Item {
                    implicitWidth: 18
                    implicitHeight: 24

                    Text {
                        anchors.centerIn: parent
                        text: root.volIcon()
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 14
                        font.weight: Font.ExtraBold
                        color: root.muted ? "#6b7fa3" : "#7cafff"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }
                Item {
                    implicitWidth: root.volumeLabelWidth
                    implicitHeight: 24

                    Text {
                        anchors.fill: parent
                        text: root.volPct + "%"
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 14
                        font.weight: Font.ExtraBold
                        color: root.muted ? "#6b7fa3" : "#7cafff"
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton)
                        Backend.ActionService.openPavucontrol();
                    else
                        Backend.AudioService.toggleMute();
                }
                onWheel: function(wheel) { root.adjustVolume(wheel.angleDelta.y > 0); }
            }
        }
    }
}
