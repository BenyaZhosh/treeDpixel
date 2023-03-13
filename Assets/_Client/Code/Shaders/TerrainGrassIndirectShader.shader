Shader "Custom/GPU Instaning/Terrain Grass Indirect"
{
    Properties {
        [NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}
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
            

            Interpolators vert (MeshData md)
            {
                Interpolators o;

                UNITY_SETUP_INSTANCE_ID(md);
                UNITY_TRANSFER_INSTANCE_ID(md, o);
                
                o.vertex = UnityObjectToClipPos(md.vertex);
                o.uv = md.uv;
                
#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED) || defined(UNITY_INSTANCING_ENABLED)
                float4x4 mat = matrixBuffer[unity_InstanceID];
                float4 meshPos = float4(mat[0].w, mat[1].w, mat[2].w, 1.0);
                
                o.screenPos = ComputeScreenPos(UnityObjectToClipPos(float4(0, -0.5, 0, 1)));
#endif
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                
                float alpha = tex2D(_MainTex, i.uv).a;
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
