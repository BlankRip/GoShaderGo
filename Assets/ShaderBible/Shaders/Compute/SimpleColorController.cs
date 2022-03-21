using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleColorController : MonoBehaviour
{
    [SerializeField] ComputeShader cShader;
    [SerializeField] Texture tex;
    [SerializeField] RenderTexture mainTex;
    [SerializeField] int texSize = 256;
    private Renderer renderer;

    private void Start() {
        mainTex = new RenderTexture(texSize, texSize, 0, RenderTextureFormat.ARGB32);
        mainTex.enableRandomWrite = true;
        mainTex.Create();
        
        renderer = GetComponent<Renderer>();
        renderer.enabled = true;

        cShader.SetTexture(0, "Result", mainTex);
        cShader.SetTexture(0, "ColTex", tex);
        renderer.material.SetTexture("_MainTex", mainTex);

        cShader.Dispatch(0, texSize/8, texSize/8, 1);
    }
}
