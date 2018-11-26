using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class Edge : MonoBehaviour
{
    public Material material;
	// Use this for initialization
	void Start ()
    {

	}
	
	// Update is called once per frame
	void Update () {
		
	}

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            //material.SetColor("_EdgeColor", _EdgeColor);
            //material.SetColor("_BackgroundColor", _BackgroundColor);
            //material.SetFloat("_EdgeOnly", _EdgeOnly);

            Graphics.Blit(src, dest, material);

        }
        else
            Graphics.Blit(src, dest);
    }

}
