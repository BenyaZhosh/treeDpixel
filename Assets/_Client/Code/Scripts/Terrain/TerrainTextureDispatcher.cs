using System;
using UnityEngine;


public class TerrainTextureDispatcher : MonoBehaviour
{
    [SerializeField] private Camera _terrainCamera;
    [SerializeField] private RenderTexture _terrainTexture;
    
    private static readonly int TerrainColorTexture = Shader.PropertyToID("_TerrainColorTexture");

    
    private void Update()
    {
        Shader.SetGlobalTexture(TerrainColorTexture, _terrainTexture);
    }
}
