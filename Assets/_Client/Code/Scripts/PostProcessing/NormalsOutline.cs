using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(NormalsOutlineRenderer), PostProcessEvent.AfterStack, "Custom/Normals Outline")]
public class NormalsOutline : PostProcessEffectSettings
{
    public Vector2Parameter resolution = new Vector2Parameter() { value = new Vector2(640, 360) };
    public FloatParameter thickness = new FloatParameter() { value = 1 };
    public FloatParameter step = new FloatParameter() { value = 1 };
    public FloatParameter density = new FloatParameter() { value = 1 };
}

public sealed class NormalsOutlineRenderer : PostProcessEffectRenderer<NormalsOutline>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/PostProcess/Normals Outline"));
        sheet.properties.SetVector("_Resolution", settings.resolution);
        sheet.properties.SetFloat("_Thickness", settings.thickness);
        sheet.properties.SetFloat("_Step", settings.step);
        sheet.properties.SetFloat("_Density", settings.density);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
