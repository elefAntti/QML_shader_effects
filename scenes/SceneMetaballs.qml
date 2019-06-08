import QtQuick 2.5
import "../effects"

Rectangle {
    width: 1000; height: 1000
    color: '#1e1e1e'
    Metaballs
    {
        width: 960; 
        NumberAnimation on uTime
        {
        	to: 30;
        	duration: 20 * 1000;
        }
    }
}