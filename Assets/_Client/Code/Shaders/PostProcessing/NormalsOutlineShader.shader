Shader "Hidden/Custom/PostProcess/Normals Outline"
{
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2);
    TEXTURE2D_SAMPLER2D(_SceneNormals, sampler_SceneNormals);
    

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float3 normal = SAMPLE_TEXTURE2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2, i.texcoord).xyz * 2 - 1;
        
        return float4(normal.xyz, 1.0);
    }
    ENDHLSL
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
                #pragma vertex VertDefault
                #pragma fragment Frag
            ENDHLSL
        }
    }
}
