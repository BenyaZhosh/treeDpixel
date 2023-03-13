Shader "Hidden/Custom/PostProcess/Depth Outline"
{
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);

    float2 _Resolution;
    float _Thickness;
    float _Threshold;
    float _Strength;
    float _Saturation;
    float _Darkness;


    float get_depth(float2 uv)
    {
        return Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv));
    }

    float4 saturate_color(float4 color, float strength)
    {
        float average = (color.r + color.g + color.b) / 3;
        return float4(
            lerp(color.r, average, strength),
            lerp(color.g, average, strength),
            lerp(color.b, average, strength), color.w);
    }
    

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

        float origin = get_depth(i.texcoord);
        
        float2 x_offset = float2(1 / _Resolution.x, 0);
        float diff_x = get_depth(i.texcoord + x_offset) - get_depth(i.texcoord - x_offset);
        float dir_x = origin - get_depth(i.texcoord - x_offset * sign(diff_x));
        float outline_x = abs(clamp(diff_x, -1, 1) * clamp(dir_x, -1, 1));

        float2 y_offset = float2(0, 1 / _Resolution.y);
        float diff_y = get_depth(i.texcoord + y_offset) - get_depth(i.texcoord - y_offset);
        float dir_y = origin - get_depth(i.texcoord - y_offset * sign(diff_y));
        float outline_y = abs(clamp(diff_y, -1, 1) * clamp(dir_y, -1, 1));

        float outline = length(float2(outline_x, outline_y));
        outline = 1 - step(pow(outline, _Strength), _Threshold);

        float2 outline_owner = i.texcoord - x_offset * sign(diff_x) - y_offset * sign(diff_y);
        float4 outline_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, outline_owner);
        outline_color = saturate_color(outline_color, _Saturation) * (1 - _Darkness);
        
        return lerp(color, outline_color, outline);
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
