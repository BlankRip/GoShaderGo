Shader "MyShaders/HealthBar"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 0
        _BorderSize ("Border Size", Range(0, 0.5)) = 0.3
        _FullColor ("Full HP Color", Color) = (1,1,1,1)
        _LowColor ("Low HP Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent"
            "Queue"="Transparent" 
        }

        Pass {
            ZWrite Off
            //src * srcAlpha + dst * (1-srcAlpha)
            Blend SrcAlpha OneMinusSrcAlpha    //Alpha Blending


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
            float _Health;
            float _BorderSize;
            float4 _FullColor;
            float4 _LowColor;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float InverseLerp(float a, float b, float v) {
                return (v-a)/(b-a);
            }

            float4 frag (v2f i) : SV_Target {
                //Clipping rounded corners
                float2 coords = i.uv;
                coords.x *= 8;
                float2 pointOnLine = float2(clamp(coords.x, 0.5, 7.5), 0.5);
                float sdf = distance(coords, pointOnLine) * 2 - 1;
                clip(-sdf);
                float borderSdf = sdf + _BorderSize;
                float borderMask = step(0, -borderSdf);

                //return float4(borderMask.xxx, 1);

                float healthBarMask = _Health > i.uv.x;
                //clip(healthBarMask - 0.01);
                
                float healthColorT = saturate(InverseLerp(0.2, 0.8, _Health));
                float3 healtBarColor = lerp(_LowColor, _FullColor, healthColorT);

                if(_Health < 0.3) {
                    float flash = (cos(_Time.y * 4) * 0.3) + 1;
                    healtBarColor *= flash;
                }

                float3 bgColor = float3(0,0,0);
                float3 outColor = lerp(bgColor, healtBarColor, healthBarMask);
                //return float4(flash.xxx, 1);

                return float4(outColor * borderMask, 1);
                //return float4(healtBarColor, healthBarMask);
            }
            ENDCG
        }
    }
}
