Shader "Custom/GPU Instaning/Terrain Grass Windy"
{
    Properties {
        [NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}
        _FramesCount ("Frames Count", int) = 5
        _WaveLength ("Wind Wave Length", float) = 1
        _WindVelocity ("Wind Direction", Vector) = (1, 0, 0, 1)
        _NoiseScale ("Noise Scale", float) = 1
        _NoiseVelocity ("Noise Velocity", Vector) = (1, 0, 0, 1)
    }
    SubShader {
        Tags { 
            "RenderType"="Opaque"
            "Queue" = "Transparent"
        }
        
        Cull Off
        Lighting Off
        ZWrite On
        Blend Off

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma instancing_options procedural:setup

            #include "UnityCG.cginc"
            #include "Assets/_Client/Code/Shaders/Utilities/NoiseUtilities/ClassicNoise3D.hlsl"
            #include "Assets/_Client/Code/Shaders/Utilities/NoiseUtilities/CustomMath.hlsl"
            

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Interpolators {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED) || defined(UNITY_INSTANCING_ENABLED)
                float4 screenPos : TEXCOORD1;
                float4 pivotPos : TEXCOORD2;
#else
                float4 worldPos : TEXCOORD1;
#endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            
            CBUFFER_START(MyData)
                float4x4 matrixBuffer[512];
            CBUFFER_END

#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            void setup() {
                unity_ObjectToWorld = matrixBuffer[unity_InstanceID];
            }
#endif


            sampler2D _TerrainColorTexture;
            sampler2D _MainTex;
            
            int _FramesCount;

            float _WaveLength;
            float4 _WindVelocity;
            float _NoiseScale;
            float4 _NoiseVelocity;
            

            Interpolators vert (MeshData md)
            {
                Interpolators o;

                UNITY_SETUP_INSTANCE_ID(md);
                UNITY_TRANSFER_INSTANCE_ID(md, o);
                
                o.vertex = UnityObjectToClipPos(md.vertex);
                o.uv = md.uv;
                
#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED) || defined(UNITY_INSTANCING_ENABLED)
                float4x4 mat = matrixBuffer[unity_InstanceID];
                o.pivotPos = float4(mat[0].w, mat[1].w, mat[2].w, 1.0);
                o.screenPos = ComputeScreenPos(UnityObjectToClipPos(float4(0, -0.5, 0, 1)));
#else
                o.worldPos = mul(unity_ObjectToWorld, o.vertex);
#endif
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED) || defined(UNITY_INSTANCING_ENABLED)
                float2 wind_pos = i.pivotPos.xz;
#else
                float2 wind_pos = i.worldPos.xz;
#endif

                float2 wind_dir = normalize(_WindVelocity.xy);
                float wave_value = sin(dot(wind_dir, wind_pos) / _WaveLength - _Time.y * _WindVelocity.w);

                float3 noise_dir = normalize(_NoiseVelocity.xyz);
                float noise_value = cnoise(float3(wind_pos / _NoiseScale, 0) - noise_dir * (_Time.y * _NoiseVelocity.w));

                float rand_offset = (random_value(wind_pos) * 2 - 1) / _FramesCount;
                
                float wind_offset = 0.5 + clamp(wave_value + noise_value + rand_offset, -1, 1) * 0.49;
                int frame = floor(wind_offset * _FramesCount);

                float2 frame_uv = float2((frame + i.uv.x) / _FramesCount, i.uv.y);
                float alpha = tex2D(_MainTex, frame_uv).a;
                clip(alpha - 0.5);

#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED) || defined(UNITY_INSTANCING_ENABLED)
                return tex2D(_TerrainColorTexture, i.screenPos);
#else
                return 1;
#endif
            }
            ENDCG
        }
    }
}
