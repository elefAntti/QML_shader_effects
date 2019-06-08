//Simulates an oscilloscope display, where a dot draws a path that slowly fades

import QtQuick 2.5

Item {
    id: container;
    width: 320; height: width
    property real dot_x: 0
    property real dot_y: 0;

    property alias fade_speed: osciloscope.fade_speed;

    Timer {
        interval: 1000/40; running: true; repeat: true
        onTriggered: 
        {
            osciloscope.old_x = osciloscope.dot_x;
            osciloscope.old_y = osciloscope.dot_y;
            osciloscope.old_intensity = osciloscope.dot_intensity;
            osciloscope.dot_x = container.dot_x;
            osciloscope.dot_y = container.dot_y;
            var dx = osciloscope.old_x - osciloscope.dot_x;
            var dy = osciloscope.old_y - osciloscope.dot_y;
            osciloscope.dot_intensity = 0.1 / Math.sqrt( dx*dx + dy*dy);
        }
    }


    ShaderEffectSource {
        id: buffer;
        width: container.width;
        height: container.height;
        sourceItem: osciloscope;
        recursive: true;
        visible: false;
    }

    ShaderEffect {
        id: osciloscope
        width: container.width;
        height: container.height;

        property variant source: buffer;
        property real dot_x: 0;
        property real dot_y: 0;
        property real dot_radius: 0.01;
        property real dot_intensity: 0.01;
        property color dot_color: "steelblue";
        property real fade_speed: 0.01;

        property real old_x:0;
        property real old_y:0;
        property real old_intensity: 0.005;



        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp float qt_Opacity;
            uniform highp float dot_x;
            uniform highp float dot_y;
            uniform highp float old_x;
            uniform highp float old_y;
            uniform highp float dot_radius;
            uniform highp float fade_speed;
            uniform vec4 dot_color;
            uniform highp float dot_intensity;
            uniform highp float old_intensity;
      
            float dist_along_capsule(vec2 start, vec2 end, vec2 point)
            {
                vec2 dir = end - start;
                float dist_along = clamp( dot( dir, (point - start) )/ dot(dir, dir), 0.0, 1.0);
                return dist_along;
            }

            float dist_capsule(vec2 start, vec2 end, vec2 point)
            {
                vec2 dir = end - start;
                float dist_along = clamp( dot( dir, (point - start) )/ dot(dir, dir), 0.0, 1.0);
                vec2 closest = start + dist_along * dir;
                return length( point - closest ); 
            }

            void main() {
                vec2 old_point = vec2( old_x * 0.5 + 0.5, old_y * 0.5 + 0.5 );
                vec2 new_point = vec2( dot_x * 0.5 + 0.5, dot_y * 0.5 + 0.5 );
                float dist = dist_capsule( old_point, new_point, qt_TexCoord0 );
                float intensity = 1.0 - smoothstep( 0.7, 1.0, dist / dot_radius); 

                //Compensate for the capsule ends overlapping
                float intensity_diminish = 1.0 - smoothstep( 0.7, 1.0, length(old_point-qt_TexCoord0) / dot_radius); 
                intensity -= intensity_diminish * (1.0 - fade_speed);

                //Remove 'steppiness' from the line
                float dist_along = dist_along_capsule(old_point, new_point, qt_TexCoord0 );
                intensity *= mix( ( 1.0 - fade_speed ) * old_intensity, dot_intensity, dist_along );

                gl_FragColor = max( texture2D(source, qt_TexCoord0 ) * (1.0 - fade_speed) + dot_color * vec4(intensity,intensity,intensity,1.0), vec4( 0.09, 0.09, 0.09, 1.0) );
                
            }"
    }
}