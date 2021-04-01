Shader "MyShaders/NoiseGround"
{
    Properties {
        _Tess("Tessellation", Range(1, 8)) = 4
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NoiseScale("Noise Scale", float) = 1
        _NoiseFrequency("Noise Frequency", float) = 1
        _NoiseOffSet("Noise Offset", Vector) = (0, 0, 0, 0)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows tessellate:tess vertex:vert
        #pragma target 4.6
        #include "noiseSimplex.cginc"

        struct appdata {
            float4 vertex: POSITION;
            float3 normal: NORMAL;
            float4 tangent: TANGENT;
            float2 texcoord: TEXCOORD0;
        };

        sampler2D _MainTex, _NormalMap;

        struct Input {
            float2 uv_MainTex;
        };

        float _Tess;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float _NoiseScale, _NoiseFrequency;
        float4 _NoiseOffSet;

        float4 tess() {
            return _Tess;
        }

        void vert(inout appdata v) {
            float3 v0 = v.vertex.xyz;
            float3 biTangent = cross(v.normal, v.tangent.xyz);
            float3 v1 = v0 + (v.tangent.xyz * 0.01);
            float3 v2 = v0 + (biTangent * 0.01);

            float ns0 = _NoiseScale * snoise(float3(v0.x + _NoiseOffSet.x, v0.y + _NoiseOffSet.y, v0.z + _NoiseOffSet.z) * _NoiseFrequency);
            v0.xyz += ((ns0 + 1)/ 2) * v.normal;
            float ns1 = _NoiseScale * snoise(float3(v1.x + _NoiseOffSet.x, v1.y + _NoiseOffSet.y, v1.z + _NoiseOffSet.z) * _NoiseFrequency);
            v1.xyz += ((ns1 + 1)/ 2) * v.normal;
            float ns2 = _NoiseScale * snoise(float3(v2.x + _NoiseOffSet.x, v2.y + _NoiseOffSet.y, v2.z + _NoiseOffSet.z) * _NoiseFrequency);
            v2.xyz += ((ns2 + 1)/ 2) * v.normal;

            float3 newNormal = cross(v2-v0, v1-v0);

            v.normal = normalize(-newNormal);
            v.vertex.xyz += v0;
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
