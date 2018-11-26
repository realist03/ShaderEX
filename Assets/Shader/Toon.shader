
Shader "Custom/Toon" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map",2D) = "white"{}
		_BumpScale("_BumpScale",Float) = 1

		_Lightness("Lightness",Range(0,100)) = 1
		_Darkness("Darkness",Range(0,100)) = 0.5
		_DiffuseDarkIntensity("_DiffuseDarkIntensity",Range(-1,1)) = 0.5
		_DarkIntensity("DarkIntensity",Range(-1,1)) = 0.5
		_LightLineIntensity("LightLineIntensity",Range(-1,1)) = 0.5

	}
	SubShader
	{
		Tags{ "LightMode" = "ForwardBase" }

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			float _Lightness;
			float _Darkness;
			float _DarkIntensity;
			float _DiffuseDarkIntensity;
			float _LightLineIntensity;


			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float3 tangentNormal : TEXCOORD3;

			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				TANGENT_SPACE_ROTATION;

				o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);

				o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)).xyz);

				o.tangentNormal = normalize(mul(rotation, v.normal).xyz);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 mapNormal;
				mapNormal = UnpackNormal(packedNormal);
				mapNormal.xy *= _BumpScale;
				mapNormal.z = sqrt(1.0 - saturate(dot(mapNormal.xy, mapNormal.xy)));

				//Diffuse
				fixed3 worldLightDir = i.lightDir;
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
				fixed theta = dot(mapNormal, worldLightDir);

				fixed3 diffuse;
				if (theta <= _DarkIntensity)
				{
					diffuse = _Color * _LightColor0 * albedo * _Darkness;

				}
				else
				{
					diffuse = _Color * _LightColor0 * albedo * _Lightness;

				}

				//ToonDiffuse
				fixed toonTheta = dot(i.tangentNormal, worldLightDir);
				fixed3 toonDiffuse;
				if (toonTheta <= _DarkIntensity)
				{
					toonDiffuse =  _Color * _LightColor0 * albedo * _Darkness;

				}
				else
				{
					toonDiffuse = _Color * _LightColor0 * albedo * _Lightness;

				}

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				//LightLine
				fixed3 viewDir = i.viewDir;
				fixed viewTheta = dot(i.tangentNormal, viewDir);
				fixed3 lightLine;
				if (theta > _DarkIntensity && viewTheta < _LightLineIntensity)
				{
					lightLine = _LightColor0;

				}
				else
				{
					lightLine = (0,0,0,0);

				}
				fixed3 finalColor = diffuse * toonDiffuse + ambient + lightLine;

				return fixed4(finalColor, 1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
