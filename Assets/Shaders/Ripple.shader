Shader "MyShaders/Ripple"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Scale("Scale", Float) = 1
        _Speed("Speed", Float) = 1
        _Frequency("Frequency", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color;
        float _Scale;
        float _Speed;
        float _Frequency;
        float _WaveAmplitude1, _WaveAmplitude2, _WaveAmplitude3, _WaveAmplitude4,
            _WaveAmplitude5, _WaveAmplitude6, _WaveAmplitude7, _WaveAmplitude8;
        float _OffSetX1, _OffSetZ1,
        _OffSetX2, _OffSetZ2,
        _OffSetX3, _OffSetZ3,
        _OffSetX4, _OffSetZ4,
        _OffSetX5, _OffSetZ5,
        _OffSetX6, _OffSetZ6,
        _OffSetX7, _OffSetZ7,
        _OffSetX8, _OffSetZ8;

        struct Input {
            float2 uv_MainTex;
        };

        void vert(inout appdata_full v) {
            half offset = (v.vertex.x * v.vertex.x) + (v.vertex.z * v.vertex.z);
            half value1 = _Scale * sin((_Time.y *_Speed * _Frequency) + (offset + (v.vertex.x * _OffSetX1) + (v.vertex.z * _OffSetZ1)));
            half value2 = _Scale * sin((_Time.y *_Speed * _Frequency) + (offset + (v.vertex.x * _OffSetX2) + (v.vertex.z * _OffSetZ2)));
            half value3 = _Scale * sin((_Time.y *_Speed * _Frequency) + (offset + (v.vertex.x * _OffSetX3) + (v.vertex.z * _OffSetZ3)));
            half value4 = _Scale * sin((_Time.y *_Speed * _Frequency) + (offset + (v.vertex.x * _OffSetX4) + (v.vertex.z * _OffSetZ4)));
            half value5 = _Scale * sin((_Time.y *_Speed * _Frequency) + (offset + (v.vertex.x * _OffSetX5) + (v.vertex.z * _OffSetZ5)));
            half value6 = _Scale * sin((_Time.y *_Speed * _Frequency) + (offset + (v.vertex.x * _OffSetX6) + (v.vertex.z * _OffSetZ6)));
            half value7 = _Scale * sin((_Time.y *_Speed * _Frequency) + (offset + (v.vertex.x * _OffSetX7) + (v.vertex.z * _OffSetZ7)));
            half value8 = _Scale * sin((_Time.y *_Speed * _Frequency) + (offset + (v.vertex.x * _OffSetX8) + (v.vertex.z * _OffSetZ8)));

            v.vertex.y += value1 * _WaveAmplitude1;
            v.vertex.y += value2 * _WaveAmplitude2;
            v.vertex.y += value3 * _WaveAmplitude3;
            v.vertex.y += value4 * _WaveAmplitude4;
            v.vertex.y += value5 * _WaveAmplitude5;
            v.vertex.y += value6 * _WaveAmplitude6;
            v.vertex.y += value7 * _WaveAmplitude7;
            v.vertex.y += value8 * _WaveAmplitude8;
            //v.normal.y += value;
        }


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
