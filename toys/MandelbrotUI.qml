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
            MouseArea
            {
                id: area
                width: parent.width
                height: parent.height
                property real x_begin: 0;
                property real y_begin: 0;
                onWheel: {
                    effect.zoom_scale *= Math.exp( wheel.angleDelta.y / 200 );
                }
                onPositionChanged: {
                    var delta_x = ( mouse.x - area.x_begin ) / area.width * 2.0;
                    var delta_y = ( mouse.y - area.y_begin ) / area.height * 2.0;
                    effect.x_center -= delta_x * effect.zoom_scale;
                    effect.y_center -= delta_y * effect.zoom_scale;
                    area.x_begin = mouse.x;
                    area.y_begin = mouse.y;
                }
                onPressed: {
                    area.x_begin = mouse.x;
                    area.y_begin = mouse.y;
                }
            }
        }
    }
}