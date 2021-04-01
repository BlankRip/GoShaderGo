using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class FogEffect : MonoBehaviour
{
    [SerializeField] Material mat;
    [SerializeField] Color fogColor;
    [SerializeField] float depthStart;
    [SerializeField] float depathDistance;
    private void Start() {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    }

    private void Update() {
        mat.SetVector("_FogColor", fogColor);
        mat.SetFloat("_DepthStart", depthStart);
        mat.SetFloat("_DepthDistance", depathDistance);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        Graphics.Blit(src, dest, mat);
    }
}
