import QtQuick 2.5
import "../effects"

Rectangle {
    width: 1000; height: 1000
    color: '#1e1e1e'
    Voxels
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