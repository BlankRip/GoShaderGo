Shader "USB/Effects/FresnelEffect" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _FresnelPow ("Fresnel Power", Range(1, 5)) = 1
        _FresnelInt ("Fresnel Intensity", Range(0, 1)) = 1
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
                float3 normal : NORMAL;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldVertex : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FresnelPow;
            float _FresnelInt;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = normalize(mul(unity_ObjectToWorld, float4(v.normal.xyz, 0))).xyz;
                o.worldVertex = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            void FresnelEffect_float (in float3 normal, in float3 viewDir, in float power, out float outPut) {
                outPut = pow(1 - saturate(dot(normal, viewDir)), power);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldVertex);
                float fresnel = 0;
                FresnelEffect_float(i.worldNormal, viewDir, _FresnelPow, fresnel);
                col += fresnel * _FresnelInt;
                return col;
            }
            ENDCG
        }
    }
}
