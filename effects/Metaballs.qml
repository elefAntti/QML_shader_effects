//Raycast scene with two reflective "metaballs" merging into one

import QtQuick 2.5

ShaderEffect {
    width: 960; height: width
    property real uTime:0;
    property real uPulse:0;
    property var lightDir:[ 0.12, 0.1, -0.2 ];

    fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform float uTime;
        uniform float uPulse;
        uniform vec3 lightDir;

        //A spirograph path, 
        // see: https://en.wikipedia.org/wiki/Spirograph
        //R is the scale parameter
        //t is time parameter
        //k is the ratio of small gear radius to large gear radius
        //l is the ratio of distance of the drawing point from the ceneter of the small gear
        //  to the radius of the small gear
        vec3 spirograph( float R, float l, float k, float t )
        {
            float a = ( 1.0 - k ) / k;
            return vec3(
                R * (( 1.0 - k ) * cos(t) + l * k * cos( a * t )),
                R * (( 1.0 - k ) * sin(t) - l * k * sin( a * t )),
                0.0
                );
        }

        // potential at given point
        float metaball( vec3 pos, float r )
        {
            return r * r / dot( pos, pos );  
        }

        //Convert metaball 'potential' to approximate distance from surface
        float dist_metab( float fPotential )
        {
            return 1.0 / sqrt( fPotential ) - 1.0;
        }

        //Returns a signeds distance of the given point to the surface of the model
        float model( vec3 pos, out int iMaterial )
        {
            vec3 objCoord = pos - vec3( 0.0, 1.0, 1.0 );
            float fModelDistance = pos.y + sin( pos.x +pos.z + uTime * 0.1 ) * 0.25;
            iMaterial = 1;

            float fMeta = dist_metab( metaball( objCoord, 0.1 + uPulse * 0.01 ) 
                + metaball( objCoord + spirograph( 0.3, 1.0, 0.3, uTime / 4.0 ), 0.05 ) ) / 12.0;

            if( fMeta < fModelDistance )
            {
                fModelDistance = fMeta;
                iMaterial = 2;
            }

            return fModelDistance;
        }

        float dist_model( vec3 pos )
        {
            int iTmp;
            return model( pos, iTmp );
        }

        float derivative_model( vec3 pos, vec3 dir, float eps )
        {
            return clamp( ( dist_model( dir * eps + pos ) - dist_model( pos ) ) / eps, 0.0, 1.0 ); 
        }

        vec3 gradient_model( vec3 pos, float eps )
        {
            return vec3( dist_model( vec3( eps, 0.0, 0.0 ) + pos ), dist_model( vec3( 0.0, eps, 0.0 ) + pos ), dist_model( vec3( 0.0, 0.0, eps ) + pos ) )
                - vec3( 1.0, 1.0, 1.0 ) * dist_model( pos );
        }

        vec3 shade_sky( vec3 rayDir )
        {
            if( dot( rayDir, lightDir ) > 0.99 )
            {
                return vec3( 1.0, 0.9, 0.7 );
            }
            return vec3( 0.6, 0.9, 0.0 ) * length( rayDir.zx ) + vec3( 0.0, 0.0, 1.0 );
        }

        vec3 phongShade( vec3 ambientColor, vec3 diffuseColor, vec3 specularColor, float fAlpha, vec3 vNormal, vec3 vLight, vec3 vCameraRay )
        {
            float fDiffuse = dot( vNormal, -vLight );
            float fSpecular = pow( clamp( dot( reflect( vLight, vNormal ), -vCameraRay ), 0.0, 1.0 ), fAlpha );
            return ambientColor + fDiffuse * diffuseColor + fSpecular * specularColor; 
        }

        vec3 texture_checker( float fSize, vec3 pos )
        {
            return vec3( mod( floor( fract( pos.x ) * 2.0 ) + floor( fract( pos.z ) * 2.0 ), 2.0 ) );
        }

        vec3 shade( vec3 pos, vec3 dir, int iMaterial )
        {
            if( iMaterial == 1 ) 
            {
                return texture_checker( 1.0, pos );
            }
            if( iMaterial == 2 ) 
            {
                vec3 vNormal = normalize( gradient_model( pos, 0.001 ) );
                return phongShade( vec3( 0.2, 0.0, 0.0 ), vec3( 0.5, 0.0, 0.0 ), vec3( 0.3, 0.3, 0.3 ), 2.0, vNormal, -lightDir, dir );
            }
            return vec3( 0.0, 0.0, 0.0 );
        }

        float shadowRay( vec3 start, vec3 dir )
        {
            float fCastLen = 2.0;
            vec3 pos = start;
            float fResult = 1.0;

            float fDistance = 0.0;

            while( fDistance < 0.002 && fCastLen < 1.0 )
            {
                fDistance = dist_model( pos );
                fCastLen += 0.01;
                pos = dir * fCastLen + start;
            }

            while( fCastLen < 100.0 )
            {
                pos = dir * fCastLen + start;
                fDistance = dist_model( pos );
                fResult = min( fResult, fDistance / fCastLen * 10.0 );
                if( fDistance < 0.001 )
                {
                    return 0.0;
                }
                fCastLen += fDistance;
            }
            return fResult; 
        }

        struct CastResult
        {
            vec3    vHit;
            vec3    vRayDir;
            vec3    vNormal;
            float   fCastLen;
            int     iMaterial;
        };

        vec3 shade( CastResult result )
        {
           if(result.iMaterial == 0)
           {
                return shade_sky( result.vRayDir );
           }
           if(result.iMaterial == 1)
           {
                return texture_checker( 1.0, result.vHit );
           }
           if(result.iMaterial == 2)
           {
               return phongShade( vec3( 0.2, 0.0, 0.0 ), vec3( 0.5, 0.0, 0.0 ), vec3( 0.3, 0.3, 0.3 ), 2.0, result.vNormal, -lightDir, result.vRayDir );
           }
           return vec3( 0.0, 0.0, 0.0 );
        }

        CastResult castRayX( vec3 vStart, vec3 vDir, float fMult )
        {
            float fCastLen = 0.0;
            vec3 vHit = vStart + vDir * 0.03;
            int iMaterial = 0;
            float fAura = 0.1;
            while( fCastLen < 100.0 )
            {
                float fDistance = model( vHit, iMaterial ) * fMult;
                fCastLen += fDistance;
                vHit = vDir * fCastLen + vStart;

                if( fDistance < 0.001 )
                {
                    vec3 vNormal = normalize( gradient_model( vHit, 0.001 ) );
                    return CastResult( vHit, vDir, vNormal, fCastLen, iMaterial );
                }
            }
            return CastResult( vStart, vDir, vec3( 0.0 ), fCastLen, 0 );
        }

        vec3 applyFog( in vec3  rgb,      // original color of the pixel
                       in float distance, // camera to point distance
                       in vec3  rayOri,   // camera position
                       in vec3  rayDir )  // camera to point vector
        {
            float c = 0.05;
            float b = 1.0;
            float fogAmount = c * exp( -rayOri.y * b ) * ( 1.0 - exp( -distance * rayDir.y * b ) ) / rayDir.y;
            float sunAmount = max( dot( rayDir, lightDir ), 0.0 );
            vec3  fogColor  = mix( vec3(0.5,0.6,0.7), // bluish
                                   vec3(1.0,0.9,0.7), // yellowish
                                   pow(sunAmount,8.0) );
            return mix( rgb, fogColor, clamp( fogAmount, 0.0, 1.0 ) );
        }


        vec3 rayTraceMain( vec2 fragCoord )
        {
            vec2 position = fragCoord * -2.0 + 1.0;
            vec3 cameraPos = vec3( 0, 1.0, -1.0 );
            vec3 rayDir = normalize( vec3( position, 2.0 ) );

            CastResult result = castRayX( cameraPos, rayDir, 1.0 );

            vec3 rawColor = shade( result );

            float fLen = result.fCastLen;

            if( result.iMaterial == 2 )
            {
                vec3 vStart = result.vHit;
                result = castRayX( result.vHit, reflect( result.vRayDir, result.vNormal ), 1.0 );
                vec3 color_2 = shade( result );
                vec3 colorWithFog_2 = applyFog( color_2, result.fCastLen, vStart, result.vRayDir );
                rawColor = mix( rawColor, colorWithFog_2, 0.2 );
            }
            vec3 colorWithFog = applyFog( rawColor, fLen, cameraPos, result.vRayDir );


            return colorWithFog;
        }


        void main()
        {
            gl_FragColor = vec4( rayTraceMain( qt_TexCoord0 ), 1.0);
        }

        "//End fragmentShader
}