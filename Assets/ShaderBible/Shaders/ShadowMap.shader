Shader "USB/ShadowMap"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        //Shadow caster Pass
        Pass {
            Name "Shadow Caster"
            Tags {
                "RenderType"="Opaque"
                "LightMode"="ShadowCaster"
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            // struct appdata {
            //     float4 vertex : POSITION;
            // };

            struct v2f {
                V2F_SHADOW_CASTER;
                //float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v) {
                v2f o;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                SHADOW_CASTER_FRAGMENT(i)
                // return 0;
            }
            ENDCG
        }

        //Default color Pass
        Pass {
            Name "Shadow Map Texture"
            Tags {
                "RenderType"="Opaque"
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata {
                float4 vertex : POSITION;
                //float2 uv : TEXCOORD0;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                //float4 vertex : SV_POSITION;
                //float4 shadowCoord : TEXCOORD1;
                float4 pos : SV_POSITION;
                SHADOW_COORDS(1)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            //sampler2D _ShadowMapTexture;

            float4 NDCToUV(float4 clipPos) {
                float4 uv = clipPos;
                #if defined(UNITY_HALF_TEXEL_OFFSET )
                uv.xy = float2(uv.x, uv.y * _ProjectionParams.x) + uv.w *
                _ScreenParams.zw;
                #else
                uv.xy = float2(uv.x, uv.y * _ProjectionParams.x) + uv.w;
                #endif
                uv.xy = float2(uv.x / uv.w, uv.y / uv.w) * 0.5;
                return uv;
            }

            v2f vert (appdata v) {
                v2f o;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.shadowCoord = NDCToUV(o.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                // fixed shadow = tex2D(_ShadowMapTexture, i.shadowCoord).a;
                fixed shadow = SHADOW_ATTENUATION(i);
                col.rgb *= shadow;
                return col;
            }
            ENDCG
        }
    }
}
