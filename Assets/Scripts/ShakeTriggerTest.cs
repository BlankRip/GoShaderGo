using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShakeTriggerTest : MonoBehaviour
{
    [SerializeField] ShakeScript shaker;
    [SerializeField] [Range(0, 1)] float maxStress = 0.6f;
    [SerializeField] float maxShakeRange = 45f;

    private void Update() {
        if(Input.GetKeyDown(KeyCode.K)) {
            float distance = Vector3.Distance(transform.position, shaker.transform.position);
            distance = Mathf.Clamp01(distance / maxShakeRange);
            float stress = (1 - Mathf.Pow(distance, 2)) * maxStress;
            shaker.AddStress(stress);
        }
    }
}
