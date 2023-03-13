#include "ClassicNoise3D.hlsl"
#include "CustomMath.hlsl"


float voronoi2D(float2 uv, float angle)
{
    float2 i_uv = floor(uv);
    float2 f_uv = frac(uv);

    float m_dist = 10;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            float2 neighbor = float2(float(x),float(y));
            
            float2 cell = random_uv(i_uv + neighbor);
            float direction = sign(0.5 - random_value(i_uv + neighbor));
            cell = 0.5 + 0.5 * sin(angle + (direction * 6.2831) * cell);
            
            float2 diff = neighbor + cell - f_uv;
            
            m_dist = min(m_dist, length(diff));
        }
    }
    
    float val = m_dist;

    return val;
}

float meta_voronoi2D(float2 uv, float angle)
{
    float2 i_uv = floor(uv);
    float2 f_uv = frac(uv);

    float f_dist = 10;
    float s_dist = 10;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            float2 neighbor = float2(float(x),float(y));
            
            float2 cell = random_uv(i_uv + neighbor);
            float direction = sign(0.5 - random_value(i_uv + neighbor));
            cell = 0.5 + 0.5 * sin(angle + (direction * 6.2831) * cell);
            float dist = length(neighbor + cell - f_uv);
            
            if (dist < f_dist) {
                s_dist = f_dist;
                f_dist = dist;
            } else if (dist < s_dist) {
                s_dist = dist;
            }
        }
    }
    
    float val = f_dist * s_dist;

    return val;
}


float linear_voronoi2D(float2 uv, float angle)
{
    float2 i_uv = floor(uv);
    float2 f_uv = frac(uv);

    float min_dist = 10;
    float2 first_cell = 0;

    float2 cells[9];

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            float2 neighbor = float2(float(x),float(y));
            
            float2 cell = random_uv(i_uv + neighbor);
            float direction = sign(0.5 - random_value(i_uv + neighbor));
            cell = 0.5 + 0.5 * sin(angle + (direction * 6.2831) * cell);

            cells[(y + 1) * 3 + (x + 1)] = i_uv + neighbor + cell;
            
            float2 diff = neighbor + cell - f_uv;
            float dist = length(diff);
            
            if (dist < min_dist)
            {
                min_dist = dist;
                first_cell = cells[(y + 1) * 3 + (x + 1)];
            }
        }
    }

    float2 cross = 10;

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            float2 current_cell = cells[(y + 1) * 3 + (x + 1)];
            
            if (length(current_cell - first_cell) > 0.01)
            {
                float2 median = (first_cell + current_cell) / 2;
                float2 normal = normalize(first_cell - median);
                float2 tangent = normalize(first_cell - uv);

                float a = tangent.y / tangent.x + normal.x / normal.y;
                float b = uv.x * (tangent.y / tangent.x) - uv.y + median.x * (normal.x / normal.y) + median.y;
                float x_cross = b / a;
                float y_cross = (x_cross - uv.x) * (tangent.y / tangent.x) + uv.y;
                float2 current_cross = float2(x_cross, y_cross);

                float old_dist = length(uv - cross);
                float new_dist = length(uv - current_cross);

                if (new_dist < old_dist && length(normalize(first_cell - uv) - normalize(first_cell - current_cross)) < 0.5)
                {
                    cross = current_cross;
                }
            }
        }
    }

    float max_dist = length(first_cell - cross);
    float val = min_dist / max_dist;

    return val;
}

float uneven_voronoi2D(float2 uv, float angle, float2 s_offset, float s_scale, float s_influence)
{
    float2 i_uv = floor(uv);
    float2 f_uv = frac(uv);

    float m_dist = 10;

    for (int y = -2; y <= 2; y++) {
        for (int x = -2; x <= 2; x++) {
            float2 neighbor = float2(float(x),float(y));
            
            float2 cell = random_uv(i_uv + neighbor);
            float direction = sign(0.5 - random_value(i_uv + neighbor));
            cell = 0.5 + 0.5 * sin(angle + (direction * 6.2831) * cell);
            
            float dist = length(neighbor + cell - f_uv);

            float2 suv = cell * s_scale - s_offset;
            float unevenness = 0.5 + cnoise(float3(suv, 0)) / (2 * s_influence);
            
            m_dist = min(m_dist, dist * unevenness);
        }
    }
    
    float val = m_dist;

    return val;
}
