// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Blur"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_IterationNumber("IterationNumber", Int) = 16
	}

		SubShader
	{
		Pass
	{
		ZTest Always

		CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag
		
		#include "UnityCG.cginc"

		uniform sampler2D _MainTex;
		uniform float _Value;
		uniform float _Value2;
		uniform float _Value3;
		uniform int _IterationNumber;

		struct a2v
		{
			float4 vertex : POSITION;
			float4 color : COLOR;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			half2 texcoord : TEXCOORD0;
			float4 vertex : SV_POSITION;
			fixed4 color : COLOR;
		};


		v2f vert(a2v Input)
		{
			v2f Output;

			Output.vertex = UnityObjectToClipPos(Input.vertex);
			Output.texcoord = Input.texcoord;
			Output.color = Input.color;

			return Output;
		}

		fixed4 frag(v2f i) : COLOR
		{
			float2 center = float2(_Value2, _Value3);
			float2 uv = i.texcoord.xy;
			uv -= center;
			float4 color = float4(0.0, 0.0, 0.0, 0.0);
			_Value *= 0.085;
			float scale = 1;

			for (int j = 1; j < _IterationNumber; ++j)
			{
				color += tex2D(_MainTex, uv * scale + center);
				scale = 1 + (float(j * _Value));
			}

			color /= (float)_IterationNumber;

			return  color;
		}

			ENDCG
		}
	}
}
