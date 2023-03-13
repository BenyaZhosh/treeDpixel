

float2 random_uv(float2 uv) {
    return frac(sin(float2(dot(uv, float2(127.1,311.7)), dot(uv, float2(269.5, 183.3)))) * 43758.5453);
}

float random_value(float2 uv)
{
    float2 noise = (frac(sin(dot(uv ,float2(12.9898,78.233)*2.0)) * 43758.5453));
    return abs(noise.x + noise.y) * 0.5;
}

float isoline(float value)
{
    return value - step(0.7, abs(sin(27 * value))) * 0.5;
}
