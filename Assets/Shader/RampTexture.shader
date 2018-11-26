Shader "CustomShader/Texture/RampShader"
{
	Properties
	{
		_RampTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader
	{
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
 
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;
 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};
 
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _RampTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
 
				return o;
			}
 
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
 
				fixed halfLambert = dot(worldNormal, lightDir) * 0.5 + 0.5;
				fixed3 color = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
 
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
 
				fixed3 diffuse = _LightColor0.rgb * color;
 
				fixed3 halfDir = normalize(viewDir + lightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
 
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
 
	FallBack "Specular"
}
