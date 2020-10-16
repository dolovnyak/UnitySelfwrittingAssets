Shader "Unlit/SpecialFX/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OcclusionMap("Occlusion", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _Transparancy ("Transparancy", Range(0.0, 1.0)) = 0.5
        _CutoutThreshold("Cutout threshhold", Range(0.0, 1.0)) = 0.2
        _Distance("Distance", float) = 1
        _Amplitude("Amplitude", float) = 1
        _Speed("Speed", float) = 1
        _Amount("Amount", Range(0.0, 1.0)) = 1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        ZWrite off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldViewDir : TEXCOORD3;
            };

            sampler2D _MainTex;            
            float4 _MainTex_ST;
            sampler2D _OcclusionMap;
            sampler2D _NormalMap;
            fixed4 _TintColor;
            float _Transparancy;
            float _CutoutThreshold;
            float _Distance;
            float _Amplitude;
            float _Speed;
            float _Amount;


            v2f vert (appdata v)
            {
                v.vertex.x += sin(_Time.y * _Speed + v.vertex.y * _Amplitude) * _Distance * _Amount;

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 worldReflect = reflect(-i.worldViewDir, i.worldNormal);
                fixed3 baseColor = tex2D(_MainTex, i.uv).rgb;
                fixed occlusion = tex2D(_OcclusionMap, i.uv).r;
                
                fixed4 color;
                color.rgb = baseColor;
                color.rgb += _TintColor;
                clip(color.rgb - _CutoutThreshold);
                color.rgb *= occlusion;
                color.a = _Transparancy;
                return color;
            }
            ENDCG
        }
    }
}
