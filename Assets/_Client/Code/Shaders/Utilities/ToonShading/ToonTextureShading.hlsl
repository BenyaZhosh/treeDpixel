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


sampler2D _ToneTex;
int _ToneLength;
float _Smoothness;

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

    float main_diffuse = floor(diffuse * _ToneLength);
    float diff = (diffuse * _ToneLength) - floor(diffuse * _ToneLength);
    
    float4 main_tone = tex2Dlod(_ToneTex, float4(main_diffuse / _ToneLength, 0.5, 0, 0));
    float4 near_tone = tex2Dlod(_ToneTex, float4((main_diffuse + 1) / _ToneLength, 0.5, 0, 0));
    
    float4 color = lerp(main_tone, near_tone, smoothstep(0.5 - _Smoothness / 2, 0.5 + _Smoothness / 2, diff));
#else
    diffuse *= round(saturate(attenuation) * _Quantization) / _Quantization;
    float4 color = diffuse;
#endif

    return color * _LightColor0;
}