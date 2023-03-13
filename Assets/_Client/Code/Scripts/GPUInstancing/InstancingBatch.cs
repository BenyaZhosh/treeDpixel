using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;

public class InstancingBatch
{
    private static readonly int MatrixPropertyId = Shader.PropertyToID("matrixBuffer");
    
    private MaterialPropertyBlock _materialProperties;
    private Bounds _bounds;
    private Mesh _mesh;
    private Material _material;
    private int _count;
    private int _layer;
    private int _layerMask;

    
    public InstancingBatch(Mesh mesh, Material material, int layer, Matrix4x4[] matrices, float maxSize, params MaterialProperties[] properties)
    {
        _mesh = mesh;
        _material = material;
        _layer = layer;

        _materialProperties = new MaterialPropertyBlock();
        _materialProperties.SetMatrixArray(MatrixPropertyId, matrices);
        
        foreach (var property in properties) {
            property.SetMaterialProperties(_materialProperties);
        }
        
        Vector3[] positions = matrices.Select(
            matrix => new Vector3(matrix.m03, matrix.m13, matrix.m23)
        ).ToArray();
        _count = positions.Length;
        _bounds = BoundsExtensions.GetBounds(positions, maxSize);
    }
    
    public InstancingBatch(Mesh mesh, Material material, int layer, MaterialPropertyBlock materialProperties, float maxSize = 0)
    {
        _mesh = mesh;
        _material = material;
        _layer = layer;
        
        _materialProperties = materialProperties;

        Vector3[] positions = materialProperties.GetMatrixArray(MatrixPropertyId).Select(
            matrix => new Vector3(matrix.m03, matrix.m13, matrix.m23)
        ).ToArray();
        _count = positions.Length;
        _bounds = BoundsExtensions.GetBounds(positions, maxSize);
    }
    
    public InstancingBatch(Mesh mesh, Material material, int layer, Matrix4x4[] matrices, float maxSize = 0)
    {
        _mesh = mesh;
        _material = material;
        _layer = layer;
        
        _materialProperties = new MaterialPropertyBlock();
        _materialProperties.SetMatrixArray(MatrixPropertyId, matrices);
        
        Vector3[] positions = matrices.Select(
            matrix => new Vector3(matrix.m03, matrix.m13, matrix.m23)
        ).ToArray();
        _count = positions.Length;
        _bounds = BoundsExtensions.GetBounds(positions, maxSize);
    }
    
    
    public void Render(Camera cam)
    {
        if ((cam.cullingMask & _layerMask) == 0) return;
        
        Graphics.DrawMeshInstancedProcedural(_mesh, 0, _material,
            bounds: _bounds,
            count: _count,
            properties: _materialProperties,
            castShadows: ShadowCastingMode.Off,
            receiveShadows: false,
            layer: _layer,
            camera: cam);
    }
}
