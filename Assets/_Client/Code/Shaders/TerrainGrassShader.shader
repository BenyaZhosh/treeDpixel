Shader "Custom/GPU Instaning/Terrain Grass"
{
    Properties {
        [NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}
        _Resolution ("Screen Resolution", Vector) = (640, 380, 0, 0)
        _PixelSize ("Pixel Size", Vector) = (16, 16, 0, 0)
    }
    SubShader {
        Tags { 
            "RenderType"="Opaque"
            "Queue" = "Transparent"
        }
        
        Cull Off
        Lighting Off
        ZWrite Off
        Blend Off

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            

            struct MeshData {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Interpolators {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wpos : TEXCOORD1;
                float4 grabPos : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            sampler2D _TerrainColorTexture;
            sampler2D _MainTex;
            
            float2 _Resolution;
            float2 _PixelSize;
            

            Interpolators vert (MeshData md)
            {
                Interpolators o;

                UNITY_SETUP_INSTANCE_ID(md);
                UNITY_TRANSFER_INSTANCE_ID(md, o);
                
                o.vertex = UnityObjectToClipPos(md.pos);
                o.uv = md.uv;
                o.wpos = mul(unity_ObjectToWorld, md.pos);
                
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.grabPos /= o.grabPos.w;
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                float2 pixel_size = float2(1. / _Resolution.x, 1. / _Resolution.y);
                float2 pixel_offset = (float2(0.5, 0) - i.uv) * _PixelSize * pixel_size;

                float4 grabColor = tex2D(_TerrainColorTexture, i.grabPos.xy + pixel_offset);
                
                float alpha = tex2D(_MainTex, i.uv).a;
                clip(alpha - 0.5);
                
                return grabColor;
            }
            ENDCG
        }
    }
}
