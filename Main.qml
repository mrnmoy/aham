import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import TCPServer

Window {
    id: window
    // width: 240
    // height: 460
    visible: true
    title: qsTr("Hello World")
    color: "#11111b"

    readonly property string displaySize: width <= 480 ? "small" : width <= 768 ? "medium" : "large"
    property string host: "localhost"
    property int port: 1234

    Settings {
        property alias port: window.port
    }

    TCPServer {
        id: tcpServer

        onServerStatusChanged: status => output.append({
                msg: status ? "Server started" : "Server stopped",
                time: getTime(),
                owner: "system"
            })
        onClientStatusChanged: status => output.append({
                msg: status ? "Client connected" : "Client disconnected",
                time: getTime(),
                owner: "system"
            })
        onReceived: msg => output.append({
                msg: msg,
                time: getTime(),
                owner: "someone"
            })
        onError: err => output.append({
                msg: "Error: " + err,
                time: getTime(),
                owner: "system"
            })
    }

    Component {
        id: stopBtnComp

        RoundButton {
            id: stopBtn
            padding: 8
            font.pixelSize: 16
            display: AbstractButton.IconOnly
            icon.source: "qrc:/res/images/ic_stop.png"
            icon.color: "#f38ba8"
            onClicked: {
                tcpServer.stop();
            }
            opacity: enabled ? 1.0 : 0.3
            background: Rectangle {
                color: parent.hovered ? "#1affffff" : "transparent"
                radius: 16
            }
        }
    }

    Component {
        id: stoppedActions

        RowLayout {
            RoundButton {
                id: connectBtn
                padding: 8
                font.pixelSize: 16
                display: AbstractButton.IconOnly
                icon.source: "qrc:/res/images/ic_connect.png"
                icon.color: "#a6e3a1"
                onClicked: {
                    tcpServer.connect(window.host, window.port);
                }
                opacity: enabled ? 1.0 : 0.3
                background: Rectangle {
                    color: parent.hovered ? "#1affffff" : "transparent"
                    radius: 16
                }
            }

            RoundButton {
                id: startBtn
                font.pixelSize: 16
                display: AbstractButton.IconOnly
                icon.source: "qrc:/res/images/ic_start.png"
                icon.color: "#a6e3a1"
                onClicked: {
                    tcpServer.start(window.host, window.port);
                }
                opacity: enabled ? 1.0 : 0.3
                background: Rectangle {
                    color: parent.hovered ? "#1affffff" : "transparent"
                    radius: 16
                }
            }
        }
    }

    Component {
        id: startedActions

        RowLayout {
            RoundButton {
                id: disconnectBtn
                padding: 8
                font.pixelSize: 16
                display: AbstractButton.IconOnly
                icon.source: "qrc:/res/images/ic_connect.png"
                icon.color: "#a6e3a1"
                enabled: tcpServer.isConnected
                onClicked: {
                    tcpServer.disconnect();
                }
                opacity: enabled ? 1.0 : 0.3
                background: Rectangle {
                    color: parent.hovered ? "#1affffff" : "transparent"
                    radius: 16
                }
            }

            Loader {
                sourceComponent: tcpServer.isListening ? stopBtnComp : undefined
            }
        }
    }

    ColumnLayout {
        spacing: 8
        anchors {
            fill: parent

            topMargin: parent.SafeArea.margins.top + spacing
            leftMargin: parent.SafeArea.margins.left + spacing
            rightMargin: parent.SafeArea.margins.right + spacing
            bottomMargin: parent.SafeArea.margins.bottom + spacing
        }

        Popup {
            id: settingsPopup
            anchors.centerIn: parent

            ColumnLayout {
                TextField {
                    id: host
                    topPadding: 8
                    rightPadding: 16
                    bottomPadding: 8
                    leftPadding: 16
                    implicitHeight: sendBtn.height
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    text: window.host
                    color: "#cdd6f4"
                    onTextChanged: {
                        window.host = parseInt(text);
                    }
                    background: Rectangle {
                        color: "#1e1e2e"
                        radius: 999
                    }
                }

                TextField {
                    id: port
                    topPadding: 8
                    rightPadding: 16
                    bottomPadding: 8
                    leftPadding: 16
                    implicitHeight: sendBtn.height
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    text: window.port
                    color: "#cdd6f4"
                    onTextChanged: {
                        window.port = parseInt(text);
                    }
                    background: Rectangle {
                        color: "#1e1e2e"
                        radius: 999
                    }
                }
            }
        }

        FlexboxLayout {
            Layout.fillHeight: false
            justifyContent: FlexboxLayout.JustifySpaceBetween
            alignItems: FlexboxLayout.AlignCenter

            RowLayout {
                Text {
                    id: appName
                    text: "Aham"
                    font.bold: true
                    font.pixelSize: 24
                    color: "#b4befe"
                    leftPadding: 8
                }

                Text {
                    id: state
                    text: "•"
                    font.weight: 500
                    font.pixelSize: 20
                    color: tcpServer.isConnected ? "#a6e3a1" : tcpServer.isListening ? "#b4befe" : "#f38ba8"
                }
            }

            RowLayout {
                Loader {
                    sourceComponent: tcpServer.isListening || tcpServer.isConnected ? startedActions : stoppedActions
                }

                RoundButton {
                    id: settingsBtn
                    padding: 8
                    font.pixelSize: 16
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/res/images/ic_settings.png"
                    icon.color: "#b4befe"
                    onClicked: {
                        settingsPopup.visible = true;
                    }
                    opacity: enabled ? 1.0 : 0.3
                    background: Rectangle {
                        color: parent.hovered ? "#1affffff" : "transparent"
                        radius: 16
                    }
                }
            }
        }

        Component {
            id: systemMsgComp

            FlexboxLayout {
                width: msgList.width
                justifyContent: FlexboxLayout.JustifyCenter

                TextField {
                    text: _msg
                    topPadding: 4
                    rightPadding: 8
                    bottomPadding: 4
                    leftPadding: 8
                    font.pixelSize: 16
                    readOnly: true
                    color: "#cdd6f4"
                    background: Rectangle {
                        radius: 8
                        color: "#1e1e2e"
                    }
                }
            }
        }

        Component {
            id: myMsgComp

            FlexboxLayout {
                width: msgList.width
                justifyContent: FlexboxLayout.JustifyEnd

                TextField {
                    text: _msg
                    topPadding: 4
                    rightPadding: 8
                    bottomPadding: 4
                    leftPadding: 8
                    font.pixelSize: 16
                    readOnly: true
                    color: "#cdd6f4"
                    background: Rectangle {
                        radius: 8
                        color: "#1e1e2e"
                    }
                }

                TextField {
                    text: _time
                    topPadding: 4
                    rightPadding: 8
                    bottomPadding: 4
                    leftPadding: 8
                    font.pixelSize: 12
                    readOnly: true
                    color: "#cdd6f4"
                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
        }

        Component {
            id: othersMsgComp

            FlexboxLayout {
                width: msgList.width
                justifyContent: FlexboxLayout.JustifyStart

                TextField {
                    text: _msg
                    topPadding: 4
                    rightPadding: 8
                    bottomPadding: 4
                    leftPadding: 8
                    font.pixelSize: 16
                    readOnly: true
                    color: "#cdd6f4"
                    background: Rectangle {
                        radius: 8
                        color: "#1e1e2e"
                    }
                }

                TextField {
                    text: _time
                    topPadding: 4
                    rightPadding: 8
                    bottomPadding: 4
                    leftPadding: 8
                    font.pixelSize: 12
                    readOnly: true
                    color: "#cdd6f4"
                    background: Rectangle {
                        color: "transparent"
                    }
                }
            }
        }

        ListModel {
            id: output
            onCountChanged: msgList.positionViewAtEnd()
        }

        ListView {
            id: msgList
            model: output
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            delegate: Loader {
                id: msgLoader
                property string _msg: msg
                property string _time: time
                sourceComponent: owner == "system" ? systemMsgComp : owner == "me" ? myMsgComp : othersMsgComp
            }
        }

        // RoundButton {
        //     x: parent.width - 40
        //     y: 8
        //     icon.color: "#f38ba8"
        //     icon.source: "qrc:/res/images/bin.png"
        //     onClicked: output.clear()
        //     background: Rectangle {
        //         color: "transparent"
        //     }
        // }

        RowLayout {
            TextField {
                id: input
                topPadding: 8
                rightPadding: 16
                bottomPadding: 8
                leftPadding: 16
                implicitHeight: sendBtn.height
                Layout.fillWidth: true
                font.pixelSize: 16
                placeholderText: qsTr("Enter your message")
                color: "#cdd6f4"
                placeholderTextColor: "#cdd6f4"
                onAccepted: onSend()
                background: Rectangle {
                    color: "#1e1e2e"
                    radius: 999
                }
            }

            RoundButton {
                id: sendBtn
                padding: 8
                font.pixelSize: 16
                display: AbstractButton.IconOnly
                icon.source: "qrc:/res/images/ic_send.png"
                enabled: tcpServer.isConnected && input.text != "" ? true : false
                onClicked: onSend()
                opacity: enabled ? 1.0 : 0.3
                background: Rectangle {
                    color: "#a6e3a1"
                    radius: 999
                    opacity: enabled ? 1.0 : 0.3
                }
            }
        }
    }

    Component.onCompleted: {
        output.append({
            msg: "Application started",
            time: getTime(),
            owner: "system"
        });
    }

    function onSend() {
        tcpServer.send(input.text);
        output.append({
            msg: input.text,
            time: getTime(),
            owner: "me"
        });
        input.clear();
    }

    function getTime() {
        var now = new Date();
        return ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2) + ":" + ("0" + now.getSeconds()).slice(-2);
    }
}
