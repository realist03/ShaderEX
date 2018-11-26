﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/6.4/SpecularVertex" 
{
	Properties {
		_Diffuse("diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss ("_Gloss", Range(0,256)) = 0.5
	}
	SubShader 
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma	vertex vert
			#pragma	fragment frag
			#include "Lighting.cginc"
				
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
				
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
				
			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;

				//转换顶点坐标到裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//转换法线到世界空间
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//计算漫反射光照
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				
				//计算反射向量
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				//计算视线向量
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				//计算高光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				
				o.color = fixed4(ambient + diffuse + specular,1.0);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4 (i.color.xyz,1.0);
			}

			ENDCG

		}
	}
	FallBack "Specular"
}
