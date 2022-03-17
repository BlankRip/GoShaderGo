Shader "USB/SpecularReflection"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInt ("Diffuse Light Intencity", Range(0, 1)) = 1
        _SpecularTex ("Specualr Texture", 2D) = "black" {}
        _SpecularInt ("Specular Light Intencity", Range(0, 1)) = 1
        _SpecularPow ("Specular Power", Range (1, 128)) = 64
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
                float3 worldVertex : TEXCOORD2;
            };

            float3 LambertShading(float3 colorRefl, float lightIntencity, float3 normal, float3 lightDir) {
                return colorRefl * lightIntencity * max(0, dot(normal, lightDir));
            }

            float3 SpecularShading(float3 colorRefl, float specularIntencity, float3 normal, float3 lightDir, float3 viewDir, float specularPow) {
                float3 halfVector = normalize(lightDir + viewDir);   //Halfway
                return colorRefl * specularIntencity * pow(max(0, dot(normal, halfVector)), specularPow);
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SpecularTex;
            float _LightInt;
            float _SpecularInt;
            float _SpecularPow;
            float4 _LightColor0;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldVertex = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldVertex);
                fixed3 colorRefl = _LightColor0.rgb;

                float3 diffuse = LambertShading(colorRefl, _LightInt, i.worldNormal, lightDir);

                fixed3 specColor = tex2D(_SpecularTex, i.uv) * colorRefl;
                half3 specular = SpecularShading(specColor, _SpecularInt, i.worldNormal, lightDir, viewDir, _SpecularPow);

                //col.rgb += specular + diffuse;
                col.rgb += specular;
                col.rgb *= diffuse;
                return col;
            }
            ENDCG
        }
    }
}
