Shader "MyShaders/Simple"
{
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 0)
        _GlowColor ("Glow Color", Color) = (1, 1, 1, 0)
        _Gloss ("Gloss", float) = 1
        _DiffSteps ("Diffuse Light Steps", float) = 2
        _SpecSteps ("Specularity Light Steps", float) = 3
        _WaterDeep ("Water Deep", Color) = (1, 1, 1, 0)
        _WaterShallow ("Water Shallow", Color) = (1, 1, 1, 0)
        _WaveColor ("Wave Color", Color) = (1, 1, 1, 0)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            //The data that you need mostly Mesh data: 
            //vertex postion, vertex normal, UVs, tangents, vertex colors
            struct InputData {
                float4 vertex : POSITION;
                float4 normal :NORMAL;
                float2 uv0 : TEXCOORD0;

                // float4 color : COLOR;
                // float4 tangent :TANGENT;
                // float2 uv1 : TEXCOORD1;
            };

            struct v2f {
                float4 clipSpacePos : SV_POSITION;
                float2 uv0 : TEXCOORD;
                float3 normal : TEXCOOD1;
                float3 worldPos : TEXCOOD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color;
            float4 _GlowColor;
            float3 _WaterDeep;
            float3 _WaterShallow;
            float3 _WaveColor;
            float _Gloss;
            float _DiffSteps;
            float _SpecSteps;
            uniform float3 _MousePos;

            //Vertex Shader
            v2f vert (InputData v) {
                v2f o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float Postarise(float steps, float value) {
                return floor(value * steps) / steps;
            }

            //Return values might see for frag shaders
            // fixed (-1 to 1)
            // half (-32000 to 32000)
            // float4 (-lots to lots)
            float4 frag (v2f i) : SV_Target {

                //frac = value = floor(value);
                // float myTexture = tex2D(_MainTex, i.uv0).x;
                // float waveSize = 0.03;
                // //float shape = i.uv0.y;
                // float shape = myTexture;
                // float waveAmp = (sin(shape / waveSize + _Time.y * 3) + 1) * 0.5;
                // waveAmp *= myTexture;

                // float3 waterColor = lerp(_WaterDeep, _WaterShallow, myTexture);
                // float3 waterWithWaves = lerp(waterColor, _WaveColor, waveAmp);

                // return float4(waterWithWaves, 0);

                float dist = distance(_MousePos, i.worldPos);
                float glow = max(0, (1 - dist));


                float2 uv = i.uv0;
                float3 normal = normalize(i.normal);
                //Lighting
                //Direct diffuse light
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;
                float lightFallOff = max(0, dot(lightDir, normal));
                //float lightFallOff = saturate(dot(lightDir, normal));
                //lightFallOff = step(0.1, lightFallOff);
                lightFallOff = Postarise(_DiffSteps, lightFallOff);
                float3 directDiffuseLight = lightColor * lightFallOff.xxx;

                //Ambient Light
                float3 ambientLight = float3(0.2, 0.2, 0.2);

                //Direct specular light
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = camPos - i.worldPos;
                float3 viewDir = normalize(fragToCam);

                float3 viewReflection = reflect(-viewDir, normal);
                float3 specularFallOff = max(0, dot(viewReflection, lightDir));
                specularFallOff = pow(specularFallOff, _Gloss); //Modified Gloss
                //specularFallOff = step(0.1, specularFallOff);
                specularFallOff = Postarise(_SpecSteps, specularFallOff);
                
                float3 directSpecular = specularFallOff.xxx * lightColor;
                //Phong
                //Blinn-Phong

                
                //Final light comnposite
                float3 diffuseLight = ambientLight + directDiffuseLight;
                float3 finalLight = (diffuseLight * _Color.rgb) + directSpecular + (glow * _GlowColor.rgb);

                return float4(finalLight, 0);
            }
            ENDCG
        }
    }
}
