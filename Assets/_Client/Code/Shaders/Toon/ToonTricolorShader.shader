Shader "Custom/Toon/Toon Tricolor" {
    Properties {
        _FirstColor     ("First Color",         Color)          = (1, 1, 1, 1)
        _SecondColor    ("Second Color",        Color)          = (1, 1, 1, 1)
        _ThirdColor     ("Third Color",         Color)          = (1, 1, 1, 1)
        _FirstThreshold ("First Threshold",     Range(0, 1))    = 0.7
        _SecondThreshold ("Second Threshold",   Range(0, 1))    = 0.3
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

            #include "Assets/_Client/Code/Shaders/Utilities/ToonShading/ToonTricolorShading.hlsl"
            
            ENDCG
        }
        
        Pass {
            Tags { "LightMode"="ForwardAdd"}
            Blend One One
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows

            #include "Assets/_Client/Code/Shaders/Utilities/ToonShading/ToonTricolorShading.hlsl"
            
            ENDCG
        }

        
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
