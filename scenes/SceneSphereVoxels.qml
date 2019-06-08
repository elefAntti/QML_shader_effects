import QtQuick 2.5
import "../effects"
import "../utils"

Rectangle {
    width: 1000; height: 700
    color: '#1e1e1e'
        Row {
        anchors.centerIn: parent
        spacing: 20
        FpsItem 
        {
            id: fpsItem
        }
        SphereVoxels
        {
            width: 700; 
            NumberAnimation on model_rotation
            {
                from: 0;
            	to: 6.283;
            	duration: 10 * 1000;
                loops: Animation.Infinite
            }
        }
    }
}