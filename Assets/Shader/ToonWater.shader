Shader "Unlit/Water"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	_MainColor("Color",COLOR) = (0.26,0.19,0.16,0.0)
		_WaveScale("Wave Scale", Float) = 0.1
		_WaveStrength("Wave Strength", Float) = 0.1
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
		// make fog work
#pragma multi_compile_fog

#include "UnityCG.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		UNITY_FOG_COORDS(1)
			float4 vertex : SV_POSITION;
	};

	float4 _MainColor;
	sampler2D _MainTex;
	float _WaveScale;
	float _WaveStrength;
	float4 _MainTex_ST;

	float calculateSurface(float x, float z, float scale)
	{
		float y = 0.0;
		y += (sin(x * 1.0 / scale + _Time.y * 1.0) + sin(x * 2.3 / scale + _Time.y * 1.5) + sin(x * 3.3 / scale + _Time.y * 0.4)) / 3.0;
		y += (sin(z * 0.2 / scale + _Time.y * 1.8) + sin(z * 1.8 / scale + _Time.y * 1.8) + sin(z * 2.8 / scale + _Time.y * 0.8)) / 3.0;
		return y;
	}

	v2f vert(appdata v)
	{
		v2f o;
		v.vertex.z += _WaveStrength * calculateSurface(v.vertex.x, v.vertex.y, _WaveScale);
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		UNITY_TRANSFER_FOG(o, o.vertex);
		return o;
	}
	fixed4 frag(v2f i) : SV_Target
	{
		float2 uv = i.uv * 10.0 + float2(_Time.y  * -0.05, _Time.y  * -0.05);

		uv.y += 0.01 * (sin(uv.x * 3.5 + _Time.y  * 0.35) + sin(uv.x * 4.8 + _Time.y  * 1.05) + sin(uv.x * 7.3 + _Time.y  * 0.45)) / 3.0;
		uv.x += 0.12 * (sin(uv.y * 4.0 + _Time.y  * 0.5) + sin(uv.y * 6.8 + _Time.y  * 0.75) + sin(uv.y * 11.3 + _Time.y  * 0.2)) / 3.0;
		uv.y += 0.12 * (sin(uv.x * 4.2 + _Time.y  * 0.64) + sin(uv.x * 6.3 + _Time.y  * 1.65) + sin(uv.x * 8.2 + _Time.y  * 0.45)) / 3.0;

		fixed4 tex1 = tex2D(_MainTex, uv * 1.0);
		fixed4 tex2 = tex2D(_MainTex, uv * 1.0 + float2(0.2, 0.2));

		float tmp = tex1.a * 0.9 - tex2.a * 0.02;
		float4 col = fixed4(_MainColor.rgb + fixed3(tmp, tmp, tmp), 1.0);
		return col;
	}

		ENDCG
	}
	}
}