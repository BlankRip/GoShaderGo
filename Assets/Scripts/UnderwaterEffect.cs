using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class UnderwaterEffect : MonoBehaviour
{   
    [Range(0.001f, 0.1f)]
    [SerializeField] float pixelOffset;
    [Range(0.1f, 20f)]
    [SerializeField] float noiseScale;
    [Range(0.1f, 20f)]
    [SerializeField] float noiseFrequency;
    [Range(0.1f, 30f)]
    [SerializeField] float noiseSpeed;
    [SerializeField] Material mat;
    
    [SerializeField] float depthStart;
    [SerializeField] float depathDistance;

    private void Update() {
        mat.SetFloat("_NoiseScale", noiseScale);
        mat.SetFloat("_NoiseFrequency", noiseFrequency);
        mat.SetFloat("_NoiseSpeed", noiseSpeed);
        mat.SetFloat("_PixelOffSet", pixelOffset);

        mat.SetFloat("_DepthStart", depthStart);
        mat.SetFloat("_DepthDistance", depathDistance);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        Graphics.Blit(src, dest, mat);
    }
    
}
