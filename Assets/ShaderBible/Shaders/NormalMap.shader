Shader "USB/NormalMap"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
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
                float4 tangent : TANGENT;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 normalUv : TEXCOORD4;
                float3 worldNormal : TEXCOORD1;
                float3 worldTangent : TEXCOORD2;
                float3 worldBinormal : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normalUv = TRANSFORM_TEX(v.uv, _NormalMap);
                o.worldNormal = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));
                o.worldTangent = normalize(mul(v.tangent, unity_WorldToObject));
                o.worldBinormal = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);

                return o;
            }

            float3 DXTCompression(float4 normalMap) {
                #if defined (UNITY_NO_DXT5nm)
                    return normalMap.rgb * 2 - 1;
                #else
                    float3 normalCol;
                    normalCol = float3(normalMap.a * 2 - 1, normalMap.g * 2 - 1, 0);
                    normalCol.b = sqrt(1 - (pow(normalCol.r, 2) + pow(normalCol.g, 2)));
                    return normalCol;
                #endif
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 normalMap = tex2D(_NormalMap, i.normalUv);
                //fixed3 compressedNormalMap = DXTCompression(normalMap);
                fixed3 compressedNormalMap = UnpackNormal(normalMap);
                float3x3 TbnMatrix = float3x3 (
                    i.worldTangent.xyz,
                    i.worldBinormal,
                    i.worldNormal
                );
                fixed3 normalMapColor = normalize(mul(compressedNormalMap, TbnMatrix));
                col.rgb *= normalMapColor;
                return col;
            }
            ENDCG
        }
    }
}
