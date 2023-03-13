using UnityEngine;


public static class BoundsExtensions
{
    public static Bounds GetBounds(Vector3[] positions, float maxSize = 0)
    {
        if (positions.Length <= 0) {
            return new Bounds(Vector3.zero, Vector3.zero);
        }

        Vector3 minPos = positions[0];
        Vector3 maxPos = positions[0];

        for (int i = 1; i < positions.Length; i++)
        {
            if (positions[i].x > maxPos.x) maxPos.x = positions[i].x;
            if (positions[i].y > maxPos.y) maxPos.y = positions[i].y;
            if (positions[i].z > maxPos.z) maxPos.z = positions[i].z;
            
            if (positions[i].x < minPos.x) minPos.x = positions[i].x;
            if (positions[i].y < minPos.y) minPos.y = positions[i].y;
            if (positions[i].z < minPos.z) minPos.z = positions[i].z;
        }

        Vector3 center = (minPos + maxPos) / 2;
        return new Bounds(center, maxPos - center + Vector3.one * (maxSize / 2));
    }
}