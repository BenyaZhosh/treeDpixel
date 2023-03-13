using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;
using Random = UnityEngine.Random;

public class GrassIndirectSpawner : MonoBehaviour
{
    private struct GrassBatch
    {
        public MaterialPropertyBlock materialProperties;
        public Bounds bounds;
        public int count;

        public GrassBatch(MaterialPropertyBlock materialProperties, float grassSize)
        {
            this.materialProperties = materialProperties;

            Vector3[] positions = materialProperties.GetMatrixArray(MatrixPropertyId).Select(
                matrix => new Vector3(matrix.m03, matrix.m13, matrix.m23)
            ).ToArray();
            count = positions.Length;

            if (count <= 0) {
                bounds = new Bounds(Vector3.zero, Vector3.zero);
                return;
            }

            Vector3 minPos = positions[0];
            Vector3 maxPos = positions[0];

            for (int i = 1; i < count; i++)
            {
                if (positions[i].x > maxPos.x) maxPos.x = positions[i].x;
                if (positions[i].y > maxPos.y) maxPos.y = positions[i].y;
                if (positions[i].z > maxPos.z) maxPos.z = positions[i].z;
                
                if (positions[i].x < minPos.x) minPos.x = positions[i].x;
                if (positions[i].y < minPos.y) minPos.y = positions[i].y;
                if (positions[i].z < minPos.z) minPos.z = positions[i].z;
            }

            Vector3 center = (minPos + maxPos) / 2;
            bounds = new Bounds(center, maxPos - center + Vector3.one * (grassSize / 2));
        }
    }
    
    
    private const int BATCH_MAX_SIZE = 512;
    
    private static readonly int MatrixPropertyId = Shader.PropertyToID("matrixBuffer");


    [Header("Spawn settings")]
    [SerializeField] private float _density;
    [SerializeField] private float _grassScale;
    [Header("Grass properties")]
    [SerializeField] private Mesh _grassMesh;
    [SerializeField] private Material _grassMaterial;
    [SerializeField] private string _grassLayerName;
    [Space(18)]
    [SerializeField] private Terrain _terrain;


    private int _grassLayer;
    private int _grassMask;
    
    private GrassBatch[] _grassBatches;


    private void ClearBatches()
    {
        _grassBatches = Array.Empty<GrassBatch>();
    }

    private void InitBatches()
    {
        ClearBatches();
        
        List<GrassBatch> batches = new List<GrassBatch>();
        
        float step = 1 / _density;
        float length = 0;
        Vector3 terrainRes = _terrain.terrainData.size;
        Vector3 terrainPos = _terrain.GetPosition();

        Matrix4x4[] matrices = new Matrix4x4[BATCH_MAX_SIZE];

        int butchIndex = 0;

        for (int i = 0; Mathf.Floor(length / terrainRes.x) * step < terrainRes.z; i++)
        {
            Vector3 objPosition = terrainPos
                                  + new Vector3(step / 2, 0, step / 2)
                                  + new Vector3(length % terrainRes.x, 0, Mathf.Floor(length / terrainRes.x) * step);
            objPosition.y = _terrain.SampleHeight(objPosition) + _grassScale / 2;
            objPosition += new Vector3((Random.value - 0.5f) * step, 0, (Random.value - 0.5f) * step / 2);
            
            matrices[i % BATCH_MAX_SIZE] = Matrix4x4.TRS(objPosition, Quaternion.Euler(30, 0, 0), Vector3.one * _grassScale);

            butchIndex++;
            if (butchIndex >= BATCH_MAX_SIZE)
            {
                MaterialPropertyBlock materialProperties = new MaterialPropertyBlock();
                materialProperties.SetMatrixArray(MatrixPropertyId, matrices);
                batches.Add(new GrassBatch(materialProperties, _grassScale));
                butchIndex = 0;
            }
            length = step * (i + 1);
        }

        _grassBatches = batches.ToArray();
    }

    private void RenderGrass(Camera cam)
    {
        if ((cam.cullingMask & _grassMask) == 0) return;
        
        foreach (var batch in _grassBatches)
        {
            CallRender(cam, batch);
        }
    }

    private void CallRender(Camera cam, GrassBatch batch)
    {
        Graphics.DrawMeshInstancedProcedural(_grassMesh, 0, _grassMaterial,
            bounds: batch.bounds,
            count: batch.count,
            properties: batch.materialProperties,
            castShadows: ShadowCastingMode.Off,
            receiveShadows: false,
            layer: _grassLayer,
            camera: cam);
    }
    
    
    private void Start()
    {
        _grassLayer = LayerMask.NameToLayer(_grassLayerName);
        _grassMask = LayerMask.GetMask(_grassLayerName);
        
        InitBatches();
        Camera.onPreCull += RenderGrass;
    }

    private void OnDisable()
    {
        ClearBatches();
        Camera.onPreCull -= RenderGrass;
    }
}
