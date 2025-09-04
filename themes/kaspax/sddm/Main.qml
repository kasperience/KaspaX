/*
 * Minimal SDDM theme for KaspaX
 *
 * This QML script defines a dark login screen with the KaspaX
 * branding. It uses a centred logo and a simple login form framed
 * by teal borders. SDDM will substitute your system’s user model
 * automatically. For further customisation, refer to the official
 * SDDM theme documentation.
 */

import QtQuick 2.12
import QtQuick.Controls 2.5
import SddmComponents 2.0

Rectangle {
    id: root
    color: "#1A1D21"
    width: 1920
    height: 1080

    // logo image centred at the top
    Image {
        id: logo
        source: "logo.png"
        width: 128
        height: 128
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 80
        fillMode: Image.PreserveAspectFit
    }

    // container for the login form
    Rectangle {
        id: form
        width: 400
        height: 220
        color: "#21252B"
        radius: 12
        border.color: "#70C7BA"
        border.width: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logo.bottom
        anchors.topMargin: 40

        // user list and password field are provided by SddmComponents
        Login {
            id: login
            anchors.fill: parent
            anchors.margins: 20
            passwordEchoMode: true
            userIconVisible: false
            backgroundColor: "#21252B"
            promptColor: "#E6E6E6"
            textColor: "#E6E6E6"
            accentColor: "#70C7BA"
        }
    }
}