Shader "MyShaders/DesolveShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DessolveTex ("Dessolve Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _DessolveAmount("Dessolve Amount", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
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

            sampler2D _MainTex, _DessolveTex;
            float4 _MainTex_ST;
            float _DessolveAmount;
            float4 _Color;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 des = tex2D(_DessolveTex, i.uv);

                clip(des.r - _DessolveAmount);

                return col;
            }
            ENDCG
        }
    }
}
