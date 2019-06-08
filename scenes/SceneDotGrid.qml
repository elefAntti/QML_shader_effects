import QtQuick 2.5
import "../effects"

Rectangle {
    width: 900; height: 900
    color: '#1e1e1e'

    Row {
        anchors.centerIn: parent
        spacing: 20

        DotGrid {
            id: effect;
            width: 700; 
            height: 700; 
        }

        SequentialAnimation {
            running: true;
            loops: Animation.Infinite

            ParallelAnimation
            {
                NumberAnimation 
                {
                    target: effect;
                    properties: "center_x";
                    to: 0.6;
                    duration: 2 * 1000;
                }
                NumberAnimation 
                {
                    target: effect;
                    properties: "center_y";
                    to: 0.6;
                    duration: 2 * 1000;
                }
            }

            NumberAnimation 
            {
                target: effect;
                properties: "center_y";
                to: 0.4;
                duration: 2 * 1000;
            }

            ParallelAnimation
            {
                NumberAnimation 
                {
                    target: effect;
                    properties: "center_x";
                    to: 0.4;
                    duration: 2 * 1000;
                }
                NumberAnimation 
                {
                    target: effect;
                    properties: "center_y";
                    to: 0.6;
                    duration: 2 * 1000;
                }
            }

            NumberAnimation 
            {
                target: effect;
                properties: "center_y";
                to: 0.4;
                duration: 2 * 1000;
            }
        }
    }
}