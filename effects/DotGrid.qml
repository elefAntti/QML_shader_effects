//Effect which renders an object using a grid of dots of various sizes
//Currently the object is a disc with a hole in the middle

import QtQuick 2.5

ShaderEffect {
    width: 320; height: width
    property color dot_color: "steelblue";
    property real grid_space: 0.1;

    //For the model
    property real center_x: 0.5;
    property real center_y: 0.5;
    property real disc_radius: 0.4;

    fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform lowp float qt_Opacity;
        uniform highp vec4 dot_color;
        uniform highp float grid_space;

        //For the model 
        uniform highp float center_x;
        uniform highp float center_y;
        uniform highp float disc_radius;

        //This model is a disc with a hole in it
        float model(vec2 coords)
        {
            float dist = length(coords - vec2(center_x, center_y));
            float intensity = smoothstep( 0.7, 1.0, dist / 0.3 ) - smoothstep( 0.7, 1.0, dist / 0.5 );
            return intensity;
        }

        void main() {
            vec2 grid_pos = ( floor( qt_TexCoord0 / grid_space ) + vec2(0.5, 0.5) )* grid_space;
            float dist = length( qt_TexCoord0 - grid_pos ) / grid_space * 2.0 ;

            //It is also interesting variation to use qt_TexCoord0 instead of grid pos
            //float radius = model(qt_TexCoord0);
            float radius = model(grid_pos);

            float intensity = 0.0;
            if(radius > 0.0)
            {
                intensity = 1.0 - smoothstep( 0.7, 1.0, dist / radius );
            }

            gl_FragColor = dot_color * intensity + vec4( 0.0, 0.0, 0.0, 1.0 );
        }"
}