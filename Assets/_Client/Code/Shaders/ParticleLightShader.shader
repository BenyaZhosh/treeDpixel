Shader "Unlit/ParticleLightShader"
{
    Properties {
    }
    SubShader
    {
        Tags { 
            "RenderType" = "Opaque"
            //"Queue" = "Overlay"
        }
        
        //ZTest Always

        Lighting Off
        ZWrite On
        Blend Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"
            

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 screenuv : TEXCOORD1;
                float depth : TEXCOORD2;
                float3 center : TEXCOORD3;
            };


            sampler2D _CameraDepthNormalsTexture;
            

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.screenuv = (o.vertex.xy / o.vertex.w + 1) / 2;
                o.screenuv.y *= _ProjectionParams.x;
                o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;
                o.center = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return length(i.center) / 1;
                
                float mask = pow(i.uv.x - 0.5, 2) + pow(i.uv.y - 0.5, 2) - 0.25;
                //clip(-mask);

                float screen_depth = DecodeFloatRG(tex2D(_CameraDepthNormalsTexture, i.screenuv).zw);
                float diff = screen_depth - i.depth;
                float intersect = 0;

                if (diff > 0)
                    intersect = 1 - smoothstep(0, _ProjectionParams.w, diff);
                
                return intersect;
            }
            ENDCG
        }
    }
}
