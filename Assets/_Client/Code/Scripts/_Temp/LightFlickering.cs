using UnityEngine;


[RequireComponent(typeof(Light))]
public class LightFlickering : MonoBehaviour
{
    [SerializeField] private float _bounds;
    [SerializeField] private float _speed;
    [SerializeField] private int _quantization;
    [SerializeField] private int _fps;
    
    private Light _light;
    private float _initialRange;


    private void Start()
    {
        _light = GetComponent<Light>();
        _initialRange = _light.range;
    }

    private void Update()
    {
        //float flicker = Mathf.Sin(Time.time * _speed);
        float flicker = Mathf.PerlinNoise(Mathf.Round(Time.time * _fps) * _speed / _fps, 0) * 2 - 1;
        _light.range = _initialRange + _bounds * Mathf.Round(flicker * _quantization) / _quantization;
    }
}
