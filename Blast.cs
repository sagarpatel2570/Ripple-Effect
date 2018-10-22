using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blast : MonoBehaviour {

    public AnimationCurve curve;
    public float blastTime = 1;
    public SpriteRenderer renderer;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if(Input.GetMouseButtonDown(0))
        {
            Vector3 inputPos = Input.mousePosition;
            Vector3 waveCenter = new Vector3(inputPos.x / Screen.width, inputPos.y / Screen.height, 0);
            renderer.material.SetVector("WaveCentre", waveCenter);
            StopAllCoroutines();
            StartCoroutine(StartEffect());
        }
	}

    IEnumerator StartEffect ()
    {
        float currentTime = 0;
        currentTime = 0.09f;
        while(currentTime <= blastTime)
        {
            currentTime += Time.deltaTime;
            renderer.material.SetFloat("time", curve.Evaluate(currentTime));
            yield return null;
        }
    }
}
