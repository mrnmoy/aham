import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import TCPServer

Window {
    id: window
    // width: 240
    // height: 460
    visible: true
    title: qsTr("Hello World")
    color: "#11111b"

    Material.theme: Material.System
    Material.accent: "#b4befe"
    Material.foreground: "#cdd6f4"
    Material.background: "#1e1e2e"
    // Material.roundedScale: Material.NotRounded

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

        Button {
            id: stopBtn
            topPadding: 8
            leftPadding: 16
            rightPadding: 16
            bottomPadding: 8
            font.pixelSize: 16
            Material.foreground: "#11111b"
            Material.background: "#f38ba8"
            Material.roundedScale: Material.FullScale
            display: window.width <= 400 ? AbstractButton.IconOnly : AbstractButton.TextBesideIcon
            icon.source: "qrc:/res/images/ic_stop.png"
            text: "Stop"
            onClicked: {
                tcpServer.stop();
            }
        }
    }

    Component {
        id: stoppedActions

        RowLayout {
            RoundButton {
                id: connectBtn
                font.pixelSize: 16
                Material.foreground: "#11111b"
                Material.background: "#a6e3a1"
                display: window.width <= 400 ? AbstractButton.IconOnly : AbstractButton.TextBesideIcon
                icon.source: "qrc:/res/images/ic_connect.png"
                text: "Connect"
                onClicked: {
                    tcpServer.connect("localhost", parseInt(port.text));
                }
            }

            Button {
                id: startBtn
                font.pixelSize: 16
                Material.foreground: "#11111b"
                Material.background: "#a6e3a1"
                display: window.width <= 400 ? AbstractButton.IconOnly : AbstractButton.TextBesideIcon
                icon.source: "qrc:/res/images/ic_start.png"
                text: "Start"
                onClicked: {
                    tcpServer.start("localhost", parseInt(port.text));
                }
            }
        }
    }

    Component {
        id: startedActions

        RowLayout {
            Button {
                id: disconnectBtn
                font.pixelSize: 16
                Material.foreground: "#11111b"
                Material.background: "#f38ba8"
                display: window.width <= 400 ? AbstractButton.IconOnly : AbstractButton.TextBesideIcon
                icon.source: "qrc:/res/images/ic_connect.png"
                text: "Disconnect"
                enabled: tcpServer.isConnected
                onClicked: {
                    tcpServer.disconnect();
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

            topMargin: parent.SafeArea.margins.top + 8
            leftMargin: parent.SafeArea.margins.left + 8
            rightMargin: parent.SafeArea.margins.right + 8
            bottomMargin: parent.SafeArea.margins.bottom + 8
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
                    text: window.width <= 400 ? "•" : tcpServer.isConnected ? "Connected" : tcpServer.isListening ? "Listening" : "Disconnected"
                    font.weight: 500
                    font.pixelSize: 20
                    color: tcpServer.isConnected ? "#a6e3a1" : tcpServer.isListening ? "#b4befe" : "#f38ba8"
                }
            }

            RowLayout {
                TextField {
                    id: port
                    // implicitHeight: parent.height
                    implicitWidth: 76
                    font.pixelSize: 16
                    text: "1234"
                    validator: IntValidator {}
                    placeholderText: qsTr("Port")
                    enabled: !tcpServer.isListening && !tcpServer.isConnected
                }

                Loader {
                    sourceComponent: tcpServer.isListening || tcpServer.isConnected ? startedActions : stoppedActions
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
                    font.pixelSize: 12
                    readOnly: true
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
                    font.pixelSize: 12
                    readOnly: true
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

        // Button {
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
                implicitHeight: sendBtn.height
                Layout.fillWidth: true
                Material.roundedScale: Material.FullScale
                font.pixelSize: 16
                placeholderText: qsTr("Enter your message")
            }

            Button {
                id: sendBtn
                font.pixelSize: 16
                Material.foreground: "#11111b"
                Material.background: "#89b4fa"
                display: window.width <= 400 ? AbstractButton.IconOnly : AbstractButton.TextBesideIcon
                icon.source: "qrc:/res/images/ic_send.png"
                text: "Send"
                enabled: tcpServer.isConnected && input.text != "" ? true : false
                onClicked: {
                    tcpServer.send(input.text);
                    output.append({
                        msg: input.text,
                        time: getTime(),
                        owner: "me"
                    });
                    input.clear();
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

    function getTime() {
        var now = new Date();
        return ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2) + ":" + ("0" + now.getSeconds()).slice(-2);
    }
}
