using System;
using UnityEngine;

public class DayNightSwitcher : MonoBehaviour
{
    [SerializeField] private Light _sunLight;
    [SerializeField] private Light _moonLight;
    [SerializeField] private bool _day;


    private void Start()
    {
        _sunLight.gameObject.SetActive(_day);
        _moonLight.gameObject.SetActive(!_day);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space)) {
            _day = !_day;
            _sunLight.gameObject.SetActive(_day);
            _moonLight.gameObject.SetActive(!_day);
        }
    }
}
