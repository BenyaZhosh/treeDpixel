using UnityEngine;


public abstract class MaterialProperties
{
    public abstract void SetMaterialProperties(MaterialPropertyBlock propertyBlock);
}

public class MaterialPropertiesInt : MaterialProperties
{
    public float[] values;
    
    private int _propertyId;

    
    protected MaterialPropertiesInt(string propertyName, float[] values)
    {
        this.values = values;
        _propertyId = Shader.PropertyToID(propertyName);
    }
    
    public override void SetMaterialProperties(MaterialPropertyBlock propertyBlock)
    {
        propertyBlock.SetFloatArray(_propertyId, values);
    }
}

public class MaterialPropertiesVector : MaterialProperties
{
    public Vector4[] values;
    
    private int _propertyId;

    
    protected MaterialPropertiesVector(string propertyName, Vector4[] values)
    {
        this.values = values;
        _propertyId = Shader.PropertyToID(propertyName);
    }
    
    public override void SetMaterialProperties(MaterialPropertyBlock propertyBlock)
    {
        propertyBlock.SetVectorArray(_propertyId, values);
    }
}

public class MaterialPropertiesMatrices : MaterialProperties
{
    public Matrix4x4[] values;
    
    private int _propertyId;

    
    protected MaterialPropertiesMatrices(string propertyName, Matrix4x4[] values)
    {
        this.values = values;
        _propertyId = Shader.PropertyToID(propertyName);
    }
    
    public override void SetMaterialProperties(MaterialPropertyBlock propertyBlock)
    {
        propertyBlock.SetMatrixArray(_propertyId, values);
    }
}