import QtQuick 2.5
import "../effects"

Rectangle {
    width: 1000; height: 1000
    color: '#1e1e1e'

    Row {
        anchors.centerIn: parent
        spacing: 20

        Image {
            id: sourceImage
            width: 320; height: width
            source: '../assets/lizard.jpeg'
            visible: false;
        }

        CRT {
            id: effect;
            width: 320; 
            property variant source: sourceImage
            NumberAnimation on scan_y {
                from: 0
                to: 1.1
                duration: 1000
                loops: Animation.Infinite
                running: true;
            }
        }

    }
}