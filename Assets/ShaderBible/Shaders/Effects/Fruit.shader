Shader "USB/Effects/Fruit"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _PlainTex ("Plain Texture", 2D) = "white" {}
        _CircleCol ("Cicrcle Color", Color) = (1, 1, 1, 1)
        _CircleRadius ("Circle Radius", Range(0.0, 0.5)) = 0.45
        _Edge ("Edge", Range (-0.5, 0.5)) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Cull Off
        LOD 100

        Pass {
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
                float4 hitPoint : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _PlainTex;
            float4 _MainTex_ST;
            float4 _CircleCol;
            float _CircleRadius;
            float _Edge;

            float PlainSDF(float3 rayPosition) {
                float plain = rayPosition.y - _Edge;
                return plain;
            }
            #define MAX_MARCHING_STEPS 50
            #define MAX_DISTANCE 10
            #define SURFACE_DISTANCE 0.001

            float SphereCasting(float3 rayOrigin, float3 rayDirection) {
                float distanceFromOrigin = 0;
                for(int i = 0; i < MAX_MARCHING_STEPS; i++) {
                    float3 rayPosition = rayOrigin + rayDirection * distanceFromOrigin;
                    float distanceInScene = PlainSDF(rayPosition);
                    distanceFromOrigin += distanceInScene;

                    if(distanceInScene < SURFACE_DISTANCE || distanceFromOrigin > MAX_MARCHING_STEPS)
                        break;
                }

                return distanceFromOrigin;
            }

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.hitPoint = v.vertex;
                return o;
            }

            fixed4 frag (v2f i, bool face : SV_isFrontFace) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                float3 rayOrigin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                float3 rayDirection = normalize(i.hitPoint - rayOrigin);

                float t = SphereCasting(rayOrigin, rayDirection);
                float4 plainCol = 0;
                float4 cirlceCol = 0;
                if(t < MAX_DISTANCE) {
                    float3 p = rayOrigin + rayDirection * t;
                    float2 uv_p = p.xz;

                    float l = pow(-abs(_Edge), 2) + pow(-abs(_Edge) - 1, 2);
                    float c = length(uv_p);

                    cirlceCol = smoothstep(c - 0.01, c + 0.01, _CircleRadius - abs(pow(_Edge * (1 * 0.5), 2)));
                    plainCol = tex2D(_PlainTex, (uv_p * (1 + abs(pow(_Edge * l, 2)))) - 0.5);
                    plainCol *= cirlceCol;
                    plainCol += (1 - cirlceCol) * _CircleCol;
                }
                    
                if(i.hitPoint.y > _Edge)
                    discard;
                return face ? col : plainCol;
            }
            ENDCG
        }
    }
}
