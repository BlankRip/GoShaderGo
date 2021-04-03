using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShakeScript : MonoBehaviour
{
    [SerializeField] float frequency = 25f;
    [SerializeField] Vector3 maxShakeTranslation = Vector3.one * 0.5f;
    [SerializeField] Vector3 maxShakeAngular = Vector3.one * 2;
    [SerializeField] float traumaExposure = 2;
    [SerializeField] float recovarySpeed = 1.5f;

    private float seed;
    private float trauma;

    private void Awake() {
        seed = Random.value;
        trauma = 0;
    }

    private void Update() {
        float shake = Mathf.Pow(trauma, traumaExposure);

        transform.localPosition = new Vector3(
            (Mathf.PerlinNoise(seed, Time.time * frequency) * 2 - 1) * maxShakeTranslation.x, 
            (Mathf.PerlinNoise(seed + 1, Time.time * frequency) * 2 - 1) * maxShakeTranslation.y, 
            (Mathf.PerlinNoise(seed + 2, Time.time * frequency) * 2 - 1) * maxShakeTranslation.z) * shake;

        transform.localRotation = Quaternion.Euler(new Vector3 (
            (Mathf.PerlinNoise(seed + 3, Time.time * frequency) * 2 - 1) * maxShakeAngular.x, 
            (Mathf.PerlinNoise(seed + 4, Time.time * frequency) * 2 - 1) * maxShakeAngular.y, 
            (Mathf.PerlinNoise(seed + 5, Time.time * frequency) * 2 - 1) * maxShakeAngular.z) * shake);

        trauma = Mathf.Clamp01(trauma - (recovarySpeed * Time.deltaTime));
    }

    public void AddStress(float stress) {
        trauma = Mathf.Clamp01(trauma + stress);
    }
}
