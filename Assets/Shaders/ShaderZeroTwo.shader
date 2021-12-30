Shader "MyShaders/ShaderZeroTwo"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Pattern2 ("Pattern 2", 2D) = "white" {}
        _Sencle ("Stencle", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define pi 3.141592653589793238462
            #define pi2 6.283185307179586476924

            #include "UnityCG.cginc"

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Sencle;
            sampler2D _Pattern2;

            float GetWave(float coord) {
                float wave = cos((coord - _Time.y * 0.1) * pi2 * 5) * 0.5 + 0.5;
                wave *= coord;
                return wave;
            }

            v2f vert (MeshData v) {
                v2f o;
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex); //Convert to world position
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // sample the texture
                float2 topDownProjection = i.worldPos.xz;
                fixed4 baseTexture = tex2D(_MainTex, topDownProjection);
                fixed4 pattern2 = tex2D(_Pattern2, topDownProjection);
                float pattern = tex2D(_Sencle, i.uv).x;

                float4 finalColor = lerp(pattern2, float4(baseTexture.xxx,1), pattern);

                return finalColor;
            }
            ENDCG
        }
    }
}