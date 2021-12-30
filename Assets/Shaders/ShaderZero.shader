Shader "MyShaders/ShaderZero"
{
    Properties {
        _ColorA("Start Color", Color) = (1,1,1,1)
        _ColorB("End Color", Color) = (1,1,1,1)
        _ColorStart("Color Start", Range(0, 1)) = 0
        _ColorEnd("Color End", Range(0, 1)) = 1
    }
    SubShader {
        Tags { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Pass {
            Cull Off
            //Cull Front
            //Cull Back
            ZWrite Off
            //ZTest LEqual   //if depth of this is less than or equal to then show it
            //ZTest Always   //Always Draw
            //ZTest GEqual   //Only draw when behind something
            Blend One One  //Additive
            // Blend DstColor Zero //Multiply

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define pi 3.141592653589793238462
            #define pi2 6.283185307179586476924

            #include "UnityCG.cginc"
            float InverseLerp(float a, float b, float v) {
                return (v-a)/(b-a);
            }

            struct MeshData {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float4 color: COLOR;
                float4 tangent: TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;  //clip space position
                float3 normal: TEXCOORD1;
            };

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

            v2f vert (MeshData v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                //float t = abs(frac(i.uv.x * 5) * 2 - 1);
                float xOffSet = cos(i.uv.x * pi2 * 8) * 0.01;
                float t = cos((i.uv.y + xOffSet - (_Time.y * 0.1)) * pi2 * 5) * 0.5 + 0.5;
                t *= 1 - i.uv.y;

                float topBottomRemover = abs(i.normal.y) < 0.999;
                float wave = t * topBottomRemover;
                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
                
                return gradient * wave;

                //Gradient with start and end
                // float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x));
                // float4 outColor = lerp(_ColorA, _ColorB, t);
                // return outColor;
            }

            ENDCG
        }
    }
}
