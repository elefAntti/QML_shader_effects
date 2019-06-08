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
            width: 80; height: width
            source: '../assets/desert2.jpeg'
            visible: false;
        }

        Mandelbrot {
            id: effect;
            width: 960; 
            property variant source: sourceImage
        }

        SequentialAnimation {
            running: true;
            ParallelAnimation
            {
                NumberAnimation 
                {
                    target: effect;
                    properties: "zoom_scale";
                    to: 1/1000;
                    duration: 20 * 1000;
                    easing.type: Easing.OutExpo;
                }
                NumberAnimation 
                {
                    target: effect;
                    properties: "eff_rotation";
                    to: 6.283;
                    duration: 10 * 1000;
                    easing.type: Easing.InOutElastic;

                }
            }
            NumberAnimation
            {
                target: effect;
                properties: "palx_point";
                to: 2.0;
                duration: 10 * 1000;
                easing.type: Easing.SineCurve;
            }
            ParallelAnimation
            {
                NumberAnimation 
                {
                    target: effect;
                    properties: "x_center";
                    to: -0.76;
                    duration: 20 * 1000;
                }
                NumberAnimation 
                {
                    target: effect;
                    properties: "y_center";
                    to: -0.0831596;
                    duration: 20 * 1000;
                }
            }
        }
    }
}