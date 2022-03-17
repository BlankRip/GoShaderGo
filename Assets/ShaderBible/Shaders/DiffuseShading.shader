Shader "USB/DiffuseShading"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInt ("Light Intencity", Range(0, 1)) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            Tags {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            float3 LambertShading(float3 colorRefl, float lightIntencity, float3 normal, float3 lightDir) {
                return colorRefl * lightIntencity * max(0, dot(normal, lightDir));
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _LightInt;
            float4 _LightColor0;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 colorRefl = _LightColor0.rgb;
                float3 diffuse = LambertShading(colorRefl, _LightInt, i.worldNormal, lightDir);
                col.rgb *= diffuse;
                return col;
            }
            ENDCG
        }
    }
}
