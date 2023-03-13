using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Random = UnityEngine.Random;

public class GrassSpawner : MonoBehaviour
{
    private const int BUTCH_SIZE = 512;
    
    
    [SerializeField] private float _density;
    [SerializeField] private float _grassScale;
    [SerializeField] private Terrain _terrain;
    [SerializeField] private Mesh _grassMesh;
    [SerializeField] private Material _grassMaterial;
    
    private GrassObjectData[][] _grassBatches;


    private void InstantiateBatchObject(List<GrassObjectData> batch, Vector3 objPosition)
    {
        Quaternion objRotation = Quaternion.Euler(30, 0, 0);
        batch.Add(new GrassObjectData(objPosition, new Vector3(_grassScale, _grassScale, 1), objRotation));
    }
    
    private void ClearBatches()
    {
        _grassBatches = Array.Empty<GrassObjectData[]>();
    }
    
    private void InitBatches()
    {
        ClearBatches();
        List<GrassObjectData[]> batches = new List<GrassObjectData[]>();
        
        float step = 1 / _density;
        float length = 0;
        Vector3 terrainRes = _terrain.terrainData.size;
        Vector3 terrainPos = _terrain.GetPosition();
        
        List<GrassObjectData> currentButch = new List<GrassObjectData>();
        int butchIndex = 0;
        
        for (int i = 0; Mathf.Floor(length / terrainRes.x) * step < terrainRes.z; i++)
        {
            Vector3 objPosition = terrainPos
                                  + new Vector3(step / 2, 0, step / 2)
                                  + new Vector3(length % terrainRes.x, 0, Mathf.Floor(length / terrainRes.x) * step);
            objPosition.y = _terrain.SampleHeight(objPosition) + _grassScale / 2;
            objPosition += new Vector3((Random.value - 0.5f) * step, 0, (Random.value - 0.5f) * step / 2);
            InstantiateBatchObject(currentButch, objPosition);
            
            butchIndex++;
            if (butchIndex >= BUTCH_SIZE)
            {
                batches.Add(currentButch.ToArray());
                currentButch = new List<GrassObjectData>();
                butchIndex = 0;
            }
            length = step * (i + 1);
        }
        
        if (!batches.Contains(currentButch.ToArray()))
            batches.Add(currentButch.ToArray());

        _grassBatches = batches.ToArray();
    }

    private void RenderBatches()
    {
        foreach (var batch in _grassBatches)
        {
            Graphics.DrawMeshInstanced(_grassMesh, 0, _grassMaterial, batch.Select((d) => d.Matrix).ToArray());
        }
    }
    
    
    private void Start()
    {
        InitBatches();
    }

    private void Update()
    {
        RenderBatches();
    }
}


public class GrassObjectData
{
    public Vector3 position;
    public Vector3 scale;
    public Quaternion rotation;

    public Matrix4x4 Matrix => Matrix4x4.TRS(position, rotation, scale);

    
    public GrassObjectData(Vector3 position, Vector3 scale, Quaternion rotation)
    {
        this.position = position;
        this.scale = scale;
        this.rotation = rotation;
    }
}
