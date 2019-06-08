//Animate the oscilloscope dot along a spirographic path

import QtQuick 2.5
import "../effects"
import "../functions/spirograph.js" as Spirograph

Rectangle {
    width: 1000; height: 1000
    color: '#1e1e1e'
    Osciloscope
    {
        id: effect;
        width: 960; 
        property real t: 0;
        dot_x: 0;
        dot_y: 0;
        fade_speed: 0.02;

        Timer {
            interval: 1000/40; running: true; repeat: true
            onTriggered: 
            {
                effect.t += 0.15

                var dot = Spirograph.spirograph(1, 0.9, 0.3, effect.t);
                effect.dot_x = dot[0];
                effect.dot_y = dot[1];
            }
        }
    }
}