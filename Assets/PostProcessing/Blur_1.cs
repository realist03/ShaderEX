using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Blur_1 : MonoBehaviour
{
    public Material material;
    Camera camera;
    public float _BlurSize = 0.5f;
    private Matrix4x4 _PreviousViewProjectionMatrix;

    private void Awake()
    {
        camera = Camera.main;

    }
    void Start()
    {
    }
    void Update()
    {

    }

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_BlurSize", _BlurSize);

            material.SetMatrix("_PreviousViewProjectionMatrix", _PreviousViewProjectionMatrix);

            Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
            Matrix4x4 _CurrentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", _CurrentViewProjectionInverseMatrix);

            _PreviousViewProjectionMatrix = currentViewProjectionMatrix;



            Graphics.Blit(src, dest, material);

        }
        else
            Graphics.Blit(src, dest);
    }

}
