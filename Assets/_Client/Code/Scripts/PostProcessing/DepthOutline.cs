using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;


[Serializable]
[PostProcess(typeof(DepthOutlineRenderer), PostProcessEvent.AfterStack, "Custom/Depth Outline")]
public class DepthOutline : PostProcessEffectSettings
{
    public Vector2Parameter resolution = new Vector2Parameter() { value = new Vector2(640, 360) };
    public FloatParameter thickness = new FloatParameter() { value = 1 };
    public FloatParameter threshold = new FloatParameter() { value = 1 };
    public FloatParameter strength = new FloatParameter() { value = 1 };
    public FloatParameter saturation = new FloatParameter() { value = 0.5f };
    public FloatParameter darkness = new FloatParameter() { value = 0.5f };
}

public sealed class DepthOutlineRenderer : PostProcessEffectRenderer<DepthOutline>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/PostProcess/Depth Outline"));
        sheet.properties.SetVector("_Resolution", settings.resolution);
        sheet.properties.SetFloat("_Thickness", settings.thickness);
        sheet.properties.SetFloat("_Threshold", settings.threshold);
        sheet.properties.SetFloat("_Strength", settings.strength);
        sheet.properties.SetFloat("_Saturation", settings.saturation);
        sheet.properties.SetFloat("_Darkness", settings.darkness);
        
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
