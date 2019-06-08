//Effect that renders an object (a rotating torus) as a collection of balls

import QtQuick 2.5

ShaderEffect {
    width: 960; height: width

    property vector3d light_direction:Qt.vector3d( 0.12, -0.1, 0.2 );
    property vector3d camera_position:Qt.vector3d(2.0, 7.0, -12.0);
    property vector3d camera_look_at:Qt.vector3d(0.0, 0.0, 0.0);
    property real camera_focal_len:1.0;
    property real camera_clip_dist: 0.0;

    property real model_rotation: 0.0;

    property real grid_space: 1.5;

    fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform vec3 light_direction;
        uniform vec3 camera_position;
        uniform vec3 camera_look_at;
        uniform float camera_focal_len;
        uniform float model_rotation;

        uniform float grid_space;

        float dist_torus( float r1, float r2, vec3 pos )
        {
            float f = length( pos.xz ) - r1;
            return length( vec2( f, pos.y ) ) - r2;
        }

        float dist_model( vec3 pos )
        {
            mat3 rotate = mat3( 1.0, 0.0                 , 0.0,
                                0.0, cos(model_rotation) , sin(model_rotation),
                                0.0, -sin(model_rotation), cos(model_rotation));
            return dist_torus( 6.0, 2.0, rotate*pos );
        }

        struct CastResult
        {
            vec3    vHit;
            vec3    vRayDir;
            vec3    vNormal;
            float   fCastLen;
            int     iMaterial;
        };

        vec3 toGridPoints( vec3 vPos )
        {
            return ( floor( vPos / grid_space ) + vec3(0.5) ) * grid_space;
        }

        float distToBoxEdge( vec3 vCenter, float fSide, vec3 vPos, vec3 vDir )
        {
            vec3 vStep = vec3( fSide * 0.7 ) * sign( vDir );
            vec3 vDist = abs( vCenter + vStep - vPos ); 
            return min( vDist.x, min( vDist.y, vDist.z ) );
        }

        CastResult castShortRay( vec3 vStart, vec3 vDir, float fMaxDist )
        {
            float fCastLen = 0.0;
            vec3 vHit = vStart;

            while( fCastLen < fMaxDist )
            {
                vec3 vGridPoint = toGridPoints( vHit );
                float radius = min( grid_space * 0.5, ( 0.5 - dist_model( vGridPoint ) ) * grid_space );

                float fDistance = max(0.0,length( vHit - vGridPoint ) - radius);

                if( fDistance < 0.001 )
                {
                    vec3 vNormal = normalize( vHit - vGridPoint );
                    return CastResult( vHit, vDir, vNormal, fCastLen / grid_space, 1 );
                }

                fCastLen += min( fDistance, distToBoxEdge( vGridPoint, grid_space, vHit, vDir ) );
                vHit = vDir * fCastLen + vStart;
            }
            return CastResult( vStart, vDir, vec3( 0.0 ), fCastLen, 0 );
        }

        mat3 cameraRotation( vec3 lookAt )
        {
            vec3 x = vec3( lookAt.z, 0, -lookAt.x ); 
            vec3 y = cross( lookAt, x );
            return mat3( x, y, lookAt );
        }

        vec3 shade( CastResult result )
        {
            if(result.iMaterial != 1)
                return vec3( 0.1, 0.0, 0.2 );
            return vec3( (0.8 + dot(light_direction, result.vNormal) * 0.2));
        }

        vec3 rayTraceMain( vec2 fragCoord, vec3 cameraPos, vec3 cameraLookAt )
        {
            vec2 position = fragCoord * 2.0 - 1.0;
            mat3 cameraR = cameraRotation( normalize( camera_look_at - cameraPos ) );
            vec3 rayDir = cameraR * normalize( vec3( position, camera_focal_len ) );

            CastResult result = castShortRay( cameraPos, rayDir, 20.0 );

            return shade(result);
        }


        void main()
        {
            gl_FragColor = vec4( rayTraceMain( qt_TexCoord0, camera_position, camera_look_at ), 1.0);
        }

        "//End fragmentShader
}