Shader "USB/FunctionLength"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Range(0.0, 0.5)) = 0.3
        _Center ("Center", Range(0, 1)) = 0.5
        _Smooth ("Smooth", Range(0.0, 0.5)) = 0.01
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Radius;
            float _Center;
            float _Smooth;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float Circle(float2 p, float center, float radius, float smoothness) {
                // create the circle
                float c = length(p - center) - radius;
                return smoothstep(c - smoothness, c + smoothness, radius);
            }

            fixed4 frag (v2f i) : SV_Target {
                float c = Circle(i.uv, _Center, _Radius, _Smooth);
                return float4(c.xxx, 1);
            }
            ENDCG
        }
    }
}
