#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"


TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);


static float2 sobel_sample_points[9] = {
    float2(-1, 1), float2(0, 1), float2(1, 1),
    float2(-1, 0), float2(0, 0), float2(1, 0),
    float2(-1, -1), float2(0, -1), float2(1, -1),
};

static float sobel_x_matrix[9] = {
    1, 0, -1,
    2, 0, -2,
    1, 0, -1
};

static float sobel_y_matrix[9] = {
     1,  2,  1,
     0,  0,  0,
    -1, -2, -1
};


float depthSobel_value(float2 uv, float2 resolution, float thickness)
{
    float2 sobel = 0;
    float origin = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv);
    [unroll] for (int i = 0; i < 9; i++) {
        float2 sobel_point = float2(sobel_sample_points[i].x / resolution.x, sobel_sample_points[i].y / resolution.y);
        float2 texcoord = uv + sobel_point * thickness;
        float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, texcoord);

        sobel += Linear01Depth(depth) * float2(sobel_x_matrix[i], sobel_y_matrix[i]);
    }

    return length(sobel);
}
