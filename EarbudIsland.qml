import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import Qt5Compat.GraphicalEffects

Scope {
    id: root
    property string deviceName: ""
    property string battery: ""
    property bool shown: false
    property bool firstPoll: true
    onShownChanged: {
        leftBud.x = 2
        leftBud.y = 2
        rightBud.x = 20
        rightBud.y = 2
        if (shown) {
            exitAnimation.stop()
            entranceAnimation.restart()
        } else {
            entranceAnimation.stop()
            exitAnimation.restart()
        }
    }

    Process {
        id: watcher
        command: root.firstPoll
            ? ["/home/fokus/island-shell/earbud-island-watch.sh", "--reset"]
            : ["/home/fokus/island-shell/earbud-island-watch.sh"]
        stdout: StdioCollector { id: output }
        onExited: {
            root.firstPoll = false
            const line = output.text.trim()
            if (line.length > 0) {
                const fields = line.split("\t")
                root.deviceName = fields[0] || "Bluetooth audio"
                root.battery = fields[1] || ""
                root.shown = true
                hideTimer.restart()
            }
            pollTimer.start()
        }
    }

    Timer {
        id: pollTimer
        interval: 2500
        running: true
        repeat: false
        onTriggered: watcher.running = true
    }
    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: root.shown = false
    }

    PanelWindow {
        id: island
        anchors { top: true; left: true; right: true }
        implicitWidth: 248
        implicitHeight: 62
        color: "transparent"
        visible: root.shown || card.opacity > 0
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "earbud-island"

        Rectangle {
            id: halo
            anchors.centerIn: card
            width: card.width + 20
            height: card.height + 12
            radius: height / 2
            color: "#35f078"
            opacity: 0
        }

        Rectangle {
            id: card
            anchors.horizontalCenter: parent.horizontalCenter
            y: -76
            width: 58
            height: 52
            radius: 26
            color: "#17191f"
            border.color: "#292c33"
            border.width: 1
            opacity: 0
            scale: 0.78
            rotation: -7
            clip: true

            SequentialAnimation {
                id: entranceAnimation
                ParallelAnimation {
                    NumberAnimation { target: card; property: "y"; from: -86; to: 12; duration: 420; easing.type: Easing.OutCubic }
                    NumberAnimation { target: card; property: "width"; from: 58; to: 224; duration: 500; easing.type: Easing.OutBack; easing.overshoot: 2.8 }
                    NumberAnimation { target: card; property: "scale"; from: 0.52; to: 1.2; duration: 500; easing.type: Easing.OutBack; easing.overshoot: 3.0 }
                    NumberAnimation { target: card; property: "rotation"; from: -16; to: 5; duration: 500; easing.type: Easing.OutBack; easing.overshoot: 2.5 }
                    NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: 130 }
                    NumberAnimation { target: halo; property: "opacity"; from: 0; to: 0.24; duration: 150 }
                }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "y"; to: 6; duration: 430; easing.type: Easing.OutBounce }
                    NumberAnimation { target: card; property: "scale"; to: 0.96; duration: 360; easing.type: Easing.OutElastic; easing.period: 0.38 }
                    NumberAnimation { target: card; property: "rotation"; to: -1.5; duration: 340; easing.type: Easing.OutBack; easing.overshoot: 2.2 }
                    NumberAnimation { target: halo; property: "opacity"; to: 0.08; duration: 430; easing.type: Easing.OutCubic }
                }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "scale"; to: 1.03; duration: 150; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "rotation"; to: 0.7; duration: 150; easing.type: Easing.OutQuad }
                }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "scale"; to: 1; duration: 260; easing.type: Easing.OutBack }
                    NumberAnimation { target: card; property: "rotation"; to: 0; duration: 260; easing.type: Easing.OutBack }
                    NumberAnimation { target: halo; property: "opacity"; to: 0; duration: 320; easing.type: Easing.OutCubic }
                }
                SequentialAnimation {
                    PauseAnimation { duration: 90 }
                    NumberAnimation { target: details; property: "opacity"; from: 0; to: 1; duration: 240; easing.type: Easing.OutCubic }
                }
            }

            ParallelAnimation {
                id: exitAnimation
                NumberAnimation { target: card; property: "y"; to: -76; duration: 260; easing.type: Easing.InCubic }
                NumberAnimation { target: card; property: "width"; to: 58; duration: 260; easing.type: Easing.InCubic }
                NumberAnimation { target: card; property: "scale"; to: 0.78; duration: 260; easing.type: Easing.InCubic }
                NumberAnimation { target: card; property: "rotation"; to: -7; duration: 260; easing.type: Easing.InCubic }
                NumberAnimation { target: card; property: "opacity"; to: 0; duration: 180 }
                NumberAnimation { target: details; property: "opacity"; to: 0; duration: 120 }
                NumberAnimation { target: halo; property: "opacity"; to: 0; duration: 150 }
            }

            Item {
                id: emoji
                anchors { left: parent.left; leftMargin: root.shown ? 10 : (card.width - width) / 2; verticalCenter: parent.verticalCenter }
                width: 42
                height: 34
                Behavior on anchors.leftMargin { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }

                Item {
                    id: emojiMask
                    anchors.fill: parent
                    Text {
                        id: leftBud
                        x: 2
                        y: 2
                        text: "ᖳ"
                        color: "white"
                        font.pixelSize: 27
                    }
                    Text {
                        id: rightBud
                        x: 20
                        y: 2
                        text: "ᖰ"
                        color: "white"
                        font.pixelSize: 27
                    }
                    visible: false
                }

                SequentialAnimation {
                    running: root.shown
                    loops: Animation.Infinite
                    NumberAnimation { target: leftBud; property: "x"; to: -1; duration: 160; easing.type: Easing.OutQuad }
                    NumberAnimation { target: leftBud; property: "x"; to: 2; duration: 220; easing.type: Easing.OutBack }
                    ParallelAnimation {
                        NumberAnimation { target: rightBud; property: "x"; to: 23; duration: 180; easing.type: Easing.OutQuad }
                        NumberAnimation { target: rightBud; property: "y"; to: -1; duration: 180; easing.type: Easing.OutQuad }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: rightBud; property: "x"; to: 20; duration: 220; easing.type: Easing.OutBack }
                        NumberAnimation { target: rightBud; property: "y"; to: 2; duration: 220; easing.type: Easing.OutBack }
                    }
                    PauseAnimation { duration: 650 }
                }

                Rectangle {
                    id: emojiGradient
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#18a957" }
                        GradientStop { position: 0.5; color: "#7ee787" }
                        GradientStop { position: 1.0; color: "#20c96b" }
                    }
                    visible: false
                }

                OpacityMask {
                    anchors.fill: parent
                    source: emojiGradient
                    maskSource: emojiMask
                }

                Item {
                    id: shineLayer
                    anchors.fill: parent
                    visible: false

                    Rectangle {
                        id: shineBar
                        x: 0
                        y: parent.height
                        width: parent.width
                        height: 2
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#00ffffff" }
                            GradientStop { position: 0.5; color: "#f5ffffff" }
                            GradientStop { position: 1.0; color: "#00ffffff" }
                        }
                        NumberAnimation on y {
                            from: emoji.height
                            to: -2
                            duration: 1250
                            loops: Animation.Infinite
                            running: root.shown
                            easing.type: Easing.InOutSine
                        }
                    }
                }

                OpacityMask {
                    anchors.fill: parent
                    source: shineLayer
                    maskSource: emojiMask
                }
            }
            Column {
                id: details
                anchors { left: parent.left; leftMargin: 54; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                opacity: 0
                spacing: 2
                Text {
                    text: root.deviceName
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: root.battery === "" ? "Connected" : root.battery + "% battery"
                    color: "#bec3ce"
                    font.pixelSize: 11
                }
            }
        }
    }
}
