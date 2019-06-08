//This effect emulates an old CRT screen

import QtQuick 2.5

Item {
    id: container;
    width: 320; height: width
    property alias scan_y: crt.scan_y
    property alias source: crt.source;

    property alias fade_speed: crt.fade_speed;
    property alias scan_line_width: crt.scan_line_width;

    ShaderEffectSource {
        id: buffer;
        width: container.width;
        height: container.height;
        sourceItem: crt;
        recursive: true;
        visible: false;
    }

    ShaderEffect {
        id: crt
        width: container.width;
        height: container.height;

        property variant previous: buffer;
        property variant source: sourceImage;
        property real fade_speed: 0.02;

        property real scan_y:0;
        property real scan_line_width:0.02;

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform sampler2D previous;
            uniform lowp float qt_Opacity;
            uniform highp float scan_y;
            uniform highp float fade_speed;
            uniform highp float scan_line_width;

            void main() {
                float intensity = pow( max(0.0, 1.0 - abs( scan_y - qt_TexCoord0.y ) / scan_line_width ), 2.0 ) ;
                gl_FragColor = texture2D(previous, qt_TexCoord0 ) * (1.0 - fade_speed) +  texture2D(source, qt_TexCoord0 ) * intensity;
                
            }"
    }
}