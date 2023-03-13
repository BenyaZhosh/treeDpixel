using System.Collections.Generic;
using UnityEngine;


public class GPUSpawner : MonoBehaviour
{
    private const int BATCH_MAX_SIZE = 512;
    
    private List<InstancingBatch> _batches;


    public void AddInstances(Mesh mesh, Material material, Matrix4x4[] matrices)
    {
        for (int index = 0, butchIndex = 0; index < matrices.Length; index++, butchIndex++) {
            
        }
    }
}
