Shader "Custom/Toon/Toon Lerp" {
    Properties {
        _FirstColor     ("First Color",         Color)          = (1, 1, 1, 1)
        _SecondColor    ("Second Color",        Color)          = (1, 1, 1, 1)
        _ShadowColor     ("Shadow Color",         Color)          = (1, 1, 1, 1)
        _ShadowThreshold ("Shadow Threshold",     Range(0, 1))    = 0.3
        _Quantization ("_Quantization", int) = 4
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        

        Pass {
            Tags { "LightMode"="ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "Assets/_Client/Code/Shaders/Utilities/ToonShading/ToonLerpShading.hlsl"
            
            ENDCG
        }
        
        Pass {
            Tags { "LightMode"="ForwardAdd"}
            Blend One One
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows

            #include "Assets/_Client/Code/Shaders/Utilities/ToonShading/ToonLerpShading.hlsl"
            
            ENDCG
        }

        
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
