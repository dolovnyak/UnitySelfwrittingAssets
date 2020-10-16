Shader "Unlit/SimpleWaterShader"
{
    Properties {
        _MainTex("Base texture", 2D) = "white" {}
        _OcclusionMap("Occlusion", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _SkyBox("Sky box", Cube) = "" {}
        _HesitationSpeed("Hesitation speed", Range(0.0, 30.0)) = 1
        _WaveSpeed("Wave speed", Range(0.0, 1.0)) = 0.1
        _Transparancy("Transparancy", Range(0.0, 1.0)) = 0.8
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        ZWrite off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _OcclusionMap;
            sampler2D _NormalMap;
            samplerCUBE _SkyBox;
            float _HesitationSpeed;
            float _WaveSpeed;
            float _Transparancy;

            struct v2f 
            {
                float3 worldPos : TEXCOORD0;
                half3 tspace0 : TEXCOORD1;
                half3 tspace1 : TEXCOORD2;
                half3 tspace2 : TEXCOORD3;
                float2 uv : TEXCOORD4;
                float4 pos : SV_POSITION;
            };

            v2f vert (float4 vertex : POSITION, float3 normal : NORMAL, float4 tangent : TANGENT, float2 uv : TEXCOORD0)
            {
                vertex.y += sin(_Time.y * _HesitationSpeed + (vertex.x * vertex.z));
                
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                o.worldPos = mul(unity_ObjectToWorld, vertex).xyz;
                half3 wNormal = UnityObjectToWorldNormal(normal);
                half3 wTangent = UnityObjectToWorldDir(tangent.xyz);
                half tangentSign = tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
                o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
                o.uv = uv;
                return o;
            }
        
            fixed4 frag (v2f i) : SV_Target
            {
                half3 tnormal = UnpackNormal(tex2D(_NormalMap, (i.uv + _Time.y * _WaveSpeed)));
                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);
                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 worldRefl = reflect(-worldViewDir, worldNormal);

                half3 skyColor = texCUBE(_SkyBox, worldRefl);
                fixed3 baseColor = tex2D(_MainTex, i.uv).rgb;
                fixed occlusion = tex2D(_OcclusionMap, i.uv).r;      
                
                fixed4 c;
                c.rgb = baseColor;
                c.rgb *= skyColor;
                c.rgb *= occlusion;
                c.a = _Transparancy;

                return c;
            }
            ENDCG
        }
    }
}
