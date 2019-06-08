//Torus made up of voxels

import QtQuick 2.5

ShaderEffect {
    width: 960; height: width

    property vector3d light_direction:Qt.vector3d( 0.12, -0.1, 0.2 );
    property vector3d camera_position:Qt.vector3d(2.0, 7.0, -12.0);
    property vector3d camera_look_at:Qt.vector3d(0.0, 0.0, 0.0);
    property real camera_focal_len:1.0;
    property real camera_clip_dist: 0.0;

    property real model_rotation: 0.0;

    property real grid_space: 0.3;

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

        mat3 cameraRotation( vec3 lookAt )
        {
            vec3 x = vec3( lookAt.z, 0, -lookAt.x ); 
            vec3 y = cross( lookAt, x );
            return mat3( x, y, lookAt );
        }

        CastResult castRayX( vec3 vStart, vec3 vDir, float fMult )
        {
            float fCastLen = 0.0;
            int iMaterial = 0;

            vec3 vGridStart = ( floor( vStart / grid_space ) + vec3(0.5) ) * grid_space;
            vec3 vStepX = vec3( grid_space, 0.0, 0.0 ) * sign( vDir.x );
            vec3 vStepY = vec3( 0.0, grid_space, 0.0 ) * sign( vDir.y );
            vec3 vStepZ = vec3(  0.0, 0.0, grid_space ) * sign( vDir.z );

            int iLastDir = 0;

            vec3 vHit = vStart;

            //The values for t where the ray crosses to next voxel
            vec3 tMax = abs( ( vGridStart + ( vStepX + vStepY + vStepZ ) * 0.5 ) - vStart) / vDir; 

            //How far we have to move in units of t to move the width of a voxel
            vec3 tDelta = (vec3(1.0, 1.0, 1.0) * grid_space) / abs(vDir); 

            int max_steps = 100;


            for( int i = 0; i < max_steps; ++i) {
                if(tMax.x < tMax.y)
                {
                    if(tMax.x < tMax.z)
                    {
                        vHit += vStepX;
                        tMax.x += tDelta.x;
                        iLastDir = 0;
                    }
                    else 
                    {
                        vHit += vStepZ;
                        tMax.z += tDelta.z;
                        iLastDir = 2;
                    }
                }
                else 
                {
                    if(tMax.y < tMax.z)
                    {
                        vHit += vStepY;
                        tMax.y += tDelta.y; 
                        iLastDir = 1;
                    }
                    else 
                    {
                        vHit += vStepZ;
                        tMax.z += tDelta.z;
                        iLastDir = 2;
                    } 
                }
                if( dist_model( vHit ) < 0.0 )
                {
                    vec3 vNormal = vec3( 0.0, 0.0, sign(vDir.z));
                    if( iLastDir == 0 ) 
                    {
                        vNormal = vec3( sign(vDir.x), 0.0, 0.0 );
                    }
                    if( iLastDir == 1 ) 
                    {
                        vNormal = vec3( 0.0, sign(vDir.y), 0.0 );
                    }            
                    return CastResult( vHit, vDir, vNormal, length( vHit - vStart )/15.0, 1 );
                }
            }

            return CastResult( vStart, vDir, vec3( 0.0 ), 0.5, 0 );
        }

        vec3 shade( CastResult result )
        {
            return vec3( (0.8 + dot(light_direction, result.vNormal) * 0.2) * (1.0 - result.fCastLen/2.0) );
        }

        vec3 rayTraceMain( vec2 fragCoord, vec3 cameraPos, vec3 cameraLookAt )
        {
            vec2 position = fragCoord * -2.0 + 1.0;
            mat3 cameraR = cameraRotation( normalize( camera_look_at - cameraPos ) );
            vec3 rayDir = cameraR * normalize( vec3( position, camera_focal_len ) );

            CastResult result = castRayX( cameraPos, rayDir, 1.0 );

            return shade(result);
        }


        void main()
        {
            gl_FragColor = vec4( rayTraceMain( qt_TexCoord0, camera_position, camera_look_at ), 1.0);
        }

        "//End fragmentShader
}