Shader "Custom/Blast"
{
	Properties
	{
		WaveParams("Wave Params",Vector) = (10,0.8,0.1)
		time("Wave Params",Float) = 0
		WaveCentre("Wave Center",Vector) = (0.5,0.5,0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"PreviewType" = "Plane"
		}

		Pass
		{
			ZWrite Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 screenuv : TEXCOORD1;
				half4 color : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.screenuv = ComputeGrabScreenPos(o.vertex);
				o.color = v.color;
				return o;
			}


			uniform sampler2D _GlobalRefractionTex;
			float3 WaveParams;
			float time;
			float3 WaveCentre;

			float4 frag(v2f i) : SV_Target
			{

				//Sawtooth function to pulse from centre.
				float t = time ;
				float offset = (t - floor(t)) / t;
				float CurrentTime = (t)*(offset);

				
				

				float2 offsetUv = i.screenuv;
				
				offsetUv.x = WaveCentre.x - i.screenuv.x;
				offsetUv.y = WaveCentre.y - i.screenuv.y;
				float Dist = sqrt(offsetUv.x * offsetUv.x + offsetUv.y * offsetUv.y);

				float4 color = tex2D(_GlobalRefractionTex,UNITY_PROJ_COORD(i.screenuv));

				//Only distort the pixels within the parameter distance from the centre
				if ((Dist <= ((CurrentTime)+(WaveParams.z))) &&
					(Dist >= ((CurrentTime)-(WaveParams.z))))
				{
					//The pixel offset distance based on the input parameters
					float Diff = (Dist - CurrentTime);
					float ScaleDiff = (1.0 - pow(abs(Diff * WaveParams.x), WaveParams.y));
					float DiffTime = (Diff  * ScaleDiff);

					//The direction of the distortion
					float2 DiffTexCoord = normalize(i.screenuv - float2(0.5,0.5));

					//Perform the distortion and reduce the effect over time
					i.screenuv += ((DiffTexCoord * DiffTime) / (CurrentTime * Dist * 40.0));
					color = tex2D(_GlobalRefractionTex, UNITY_PROJ_COORD(i.screenuv));

					//Blow out the color and reduce the effect over time
					color += (color * ScaleDiff) / (CurrentTime * Dist * 40.0);
				}

				return color;
			}
			ENDCG
		}
	}

	Fallback "Sprites/Default"
}