Shader "MyPostEffects/UnderWaterImageEffect"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale("Noise Scale", float) = 1
        _NoiseFrequency("Noise Frequency", float) = 1
        _NoiseSpeed("Noise Speed", float) = 1
        _PixelOffSet("Pixel Offset", float) = 0.005
    }
    SubShader {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "noiseSimplex.cginc"
            #define pi 3.1415926535897932384626433832795

            uniform float _NoiseScale, _NoiseFrequency, _NoiseSpeed, _PixelOffSet;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos: TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : COLOR
            {
                float3 sPos = float3(i.screenPos.x, i.screenPos.y, 0) * _NoiseFrequency;
                sPos.z += _Time.x * _NoiseSpeed;
                float noise = _NoiseScale * ((snoise(sPos) + 1) / 2);
                float4 nosieToDir = normalize(float4(cos(noise * pi * 2), sin(noise * pi * 2), 0, 0));
                fixed4 col = tex2Dproj(_MainTex, i.screenPos + (nosieToDir * _PixelOffSet));
                return col;
            }
            ENDCG
        }
    }
}
