Shader "MyShaders/ShaderZeroOne"
{
    Properties {
        // _ColorA("Start Color", Color) = (1,1,1,1)
        // _ColorB("End Color", Color) = (1,1,1,1)
        _WaveAmplitude("Wave Amplitude", Range(0, 0.3)) = 0.1
    }
    SubShader {
        Tags { 
            "RenderType"="Opaque"
        }

        Pass {

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
            float _WaveAmplitude;

            
            float GetWave(float2 uv) {
                float2 centeredUV = uv * 2 -1;
                float radialDistance = length(centeredUV);
                float wave = cos((radialDistance - _Time.y * 0.1) * pi2 * 5);
                wave *= 1 - radialDistance;
                return wave;
            }

            v2f vert (MeshData v) {
                v2f o;
                // float wave = cos((v.uv.y - _Time.y * 0.1) * pi2 * 5);
                // float wave2 = cos((v.uv.x - _Time.y * 0.1) * pi2 * 5);
                // v.vertex.y = wave * wave2 * _WaveAmplitude;

                v.vertex.y = GetWave(v.uv) * _WaveAmplitude;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                return GetWave(i.uv);

                // float topBottomRemover = abs(i.normal.y) < 0.999;
                // float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
                
                // return gradient * wave;
            }

            ENDCG
        }
    }
}