//Render the mandelbrot set using an image as the pallette

import QtQuick 2.5

ShaderEffect {
    width: 320; height: width
    // the source image to use as the pallette
    property variant source;
    //The position to center on
    property real x_center: -0.761574;
    property real y_center: -0.0847596;
    property real zoom_scale: 3.0;
    //The column of the image to use as the pallette
    property real palx_point: 0.0;
    //The rotation of the effect around the center
    property real eff_rotation: 0.0;


    fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform sampler2D source;
        uniform lowp float qt_Opacity;
        uniform highp float x_center;
        uniform highp float y_center;
        uniform highp float zoom_scale;
        uniform lowp float palx_point;
        uniform highp float eff_rotation;

        bool inCardioid( float x, float y )
        {
            float q = ( x - 0.25 ) * ( x - 0.25 ) + y * y;
            return q * ( q + x - 0.25 ) < 0.25 * y * y;
        }

        float mandelbrot( vec2 c )
        {
            if( inCardioid( c.x, c.y ) )
                return 0.0;

            vec2 z = vec2( 0, 0 );
            for( int i = 0; i < 600; i += 1 )
            {
                vec2 z2 = z * z;
                z = vec2( z2.x - z2.y , 2.0 * z.x * z.y ) + c;
                if( dot( z, z ) > 4.0 )
                    return float(i) / 300.0;
            }
            return 0.0;
        }

        void main() {
            vec2 position = qt_TexCoord0 * 2.0 - 1.0;
            mat2 matRotate = mat2( cos(eff_rotation), sin(eff_rotation), -sin(eff_rotation), cos(eff_rotation) );
            position = position * matRotate * zoom_scale + vec2( x_center, y_center );
            gl_FragColor = texture2D(source, mandelbrot( position.xy ) * vec2( palx_point, 1.0 ) ) * qt_Opacity;
        }"
}