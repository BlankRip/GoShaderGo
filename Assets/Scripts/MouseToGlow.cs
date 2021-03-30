using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseToGlow : MonoBehaviour
{
    Camera camera;

    private void Start() {
        camera = GetComponent<Camera>();
    }

    private void Update() {
        Plane p = new Plane(Vector3.up, Vector3.zero);
        Vector2 mousePos = Input.mousePosition;
        Ray ray = camera.ScreenPointToRay(mousePos);
        if(p.Raycast(ray, out float enterDist)) {
            Vector3 worldMousPos = ray.GetPoint(enterDist);

            Shader.SetGlobalVector("_MousePos", worldMousPos);
        }
    }
}
