Shader "Custom/Toon/Toon Texture" {
    Properties {
        _ToneTex ("Tone Texture", 2D) = "white" {}
        _ToneLength ("Tone Length", int) = 10
        _Smoothness ("Smoothness", Range(0, 1)) = 0.1
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

            #include "Assets/_Client/Code/Shaders/Utilities/ToonShading/ToonTextureShading.hlsl"
            
            ENDCG
        }
        
        Pass {
            Tags { "LightMode"="ForwardAdd"}
            Blend One One
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows

            #include "Assets/_Client/Code/Shaders/Utilities/ToonShading/ToonTextureShading.hlsl"
            
            ENDCG
        }

        
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
