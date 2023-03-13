#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

            
struct MeshData {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct Interpolators {
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 wpos : TEXCOORD2;
    LIGHTING_COORDS(3,4)
};
            
            
float4 _FirstColor;
float4 _SecondColor;
float4 _ShadowColor;

float _ShadowThreshold;

int _Quantization;
            

Interpolators vert (MeshData v)
{
    Interpolators o;
                
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.wpos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_VERTEX_TO_FRAGMENT(o);
                
    return o;
}

float4 frag (Interpolators i) : SV_Target
{
    float attenuation = LIGHT_ATTENUATION(i);
                
    float3 normal = normalize(i.normal);
    float3 light_diff = UnityWorldSpaceLightDir(i.wpos);
    float diffuse = saturate(dot(normal, normalize(light_diff)));

#ifdef DIRECTIONAL
    diffuse *= saturate(attenuation);
    
    float4 color = lerp(_SecondColor, _FirstColor, (diffuse - _ShadowThreshold) / (1 - _ShadowThreshold));
    color = lerp(_ShadowColor, color, step(_ShadowThreshold, diffuse));
#else
    diffuse *= round(saturate(attenuation) * _Quantization) / _Quantization;
    float4 color = diffuse;
#endif

    return color * _LightColor0;
}