using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RippleCollisionScript : MonoBehaviour
{
    [SerializeField] float velMagDivie;
    private float distanceX, distanceZ;
    Vector3 distance;
    private int waveNumber = 1;
    private float[] waveAmplitude;
    private Renderer renderer;
    private Mesh mesh;

    private void Start() {
        renderer = GetComponent<Renderer>();
        mesh = GetComponent<MeshFilter>().mesh;
        waveAmplitude = new float[8];
    }

    private void Update() {
        for (int i = 0; i < 8; i++) {
            waveAmplitude[i] = renderer.material.GetFloat($"_WaveAmplitude{i + 1}");
            if(waveAmplitude[i] > 0)
                renderer.material.SetFloat($"_WaveAmplitude{i + 1}", waveAmplitude[i] * 0.98f);
            if(waveAmplitude[i] < 0.05f)
                renderer.material.SetFloat($"_WaveAmplitude{i + 1}", 0);
        }
    }

    private void OnCollisionEnter(Collision other) {
        if(other.rigidbody != null) {
            waveNumber++;
            if(waveNumber == 9) {
                waveNumber = 1;
            }
            waveAmplitude[waveNumber - 1] = 0;

            Debug.Log(this.transform.position.x);
            Debug.Log(other.gameObject.transform.position.x);
            distanceX = this.transform.position.x - other.gameObject.transform.position.x;
            Debug.Log(distanceX);
            distanceZ = this.transform.position.z - other.gameObject.transform.position.z;

            renderer.material.SetFloat($"_OffSetX{waveNumber}", distanceX / mesh.bounds.size.x * 2.5f);
            renderer.material.SetFloat($"_OffSetZ{waveNumber}", distanceZ / mesh.bounds.size.z * 2.5f);

            renderer.material.SetFloat($"_WaveAmplitude{waveNumber}", other.rigidbody.velocity.magnitude * velMagDivie);
        }
    }
}
