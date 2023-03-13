using UnityEngine;


[RequireComponent(typeof(Camera))]
public class RenderDepthNormals : MonoBehaviour
{
    [ExecuteInEditMode]
    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
    }
}
