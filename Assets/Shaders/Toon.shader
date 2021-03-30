Shader "MyShaders/Toon" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        [HDR]
        _AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
        [HDR]
        _SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
        _Glossiness("Gloss", Float) = 32
        [HDR]
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimAmount("Rim Amount", Range(0, 1)) = 0.716
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }
    SubShader {
        Tags { 
            //"RenderType"="Opaque"
            "LightMode" = "ForwardBase"
	        "PassFlags" = "OnlyDirectional"
        }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata {
                float4 pos : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float3 worldNormal: NORMAL;
                float3 viewDir: TEXCOORD1;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            float4 _AmbientColor;

            float4 _SpecularColor;
            float _Glossiness;

            float4 _RimColor;
            float _RimAmount;
            float _RimThreshold;

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.pos);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // sample the texture
                fixed4 texSample = tex2D(_MainTex, i.uv);
                float shadow = SHADOW_ATTENUATION(i);

                //Diffuse light
                float3 normal = normalize(i.worldNormal);
                float nDotL = dot(_WorldSpaceLightPos0, normal);
                float diffuseLightIntensity = smoothstep(0, 0.01, nDotL * shadow);
                float diffuseLight = diffuseLightIntensity * _LightColor0;

                //Specualr Reflections
                float3 viewDir = normalize(i.viewDir);
                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float3 nDotH = dot(halfVector, normal);
                float specularIntensity = pow(nDotH * diffuseLightIntensity, _Glossiness * _Glossiness);
                specularIntensity = smoothstep(0.005, 0.01, specularIntensity);
                float specularLight = specularIntensity * _SpecularColor;

                //Rim Light
                float4 rimDot = 1 - dot(viewDir, normal);
                float rimIntensity = rimDot * pow(nDotL, _RimThreshold);
                rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
                float4 rimLight = rimIntensity * _RimColor;
                
                float4 finalLight = _AmbientColor + diffuseLight + specularLight + rimLight;
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return _Color * texSample * finalLight;
            }
            ENDCG
        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
