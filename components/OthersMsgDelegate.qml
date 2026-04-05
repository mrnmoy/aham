import QtQuick
import QtQuick.Controls

Row {
    TextField {
        text: msg
        font.pixelSize: 16
        readOnly: true
        background: Rectangle {
            color: "transparent"
        }
    }
    TextField {
        text: time
        font.pixelSize: 12
        readOnly: true
        background: Rectangle {
            color: "transparent"
        }
    }
}
