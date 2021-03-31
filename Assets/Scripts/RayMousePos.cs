using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayMousePos : MonoBehaviour
{
    private Camera cam;
    private RaycastHit hitInfo;
    private Ray ray;
    private Vector3 mousePos, smoothPoint;
    public float radius, softness, smoothSpeed, scaleFactor;


    private void Start() {
        cam = GetComponent<Camera>();
    }

    private void Update() {
        if(Input.GetKey(KeyCode.UpArrow)) {
            radius += scaleFactor * Time.deltaTime;
        }
        if(Input.GetKey(KeyCode.DownArrow)) {
            radius -= scaleFactor * Time.deltaTime;
        }
        if(Input.GetKey(KeyCode.RightArrow)) {
            softness += scaleFactor * Time.deltaTime;
        }
        if(Input.GetKey(KeyCode.LeftArrow)) {
            softness -= scaleFactor * Time.deltaTime;
        }
        Mathf.Clamp(radius, 0, 100);
        Mathf.Clamp(softness, 0, 100);

        mousePos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 0);
        ray = cam.ScreenPointToRay(mousePos);
        if(Physics.Raycast(ray, out hitInfo)) {
            smoothPoint = Vector3.MoveTowards(smoothPoint, hitInfo.point, smoothSpeed * Time.deltaTime);
            Vector4 pos = new Vector4(smoothPoint.x, smoothPoint.y, smoothPoint.z, 0);
            Shader.SetGlobalVector("GlobalMask_Position", pos);
        }
        Shader.SetGlobalFloat("GlobalMask_Radius", radius);
        Shader.SetGlobalFloat("GlobalMask_Softness", softness);
    }
}
