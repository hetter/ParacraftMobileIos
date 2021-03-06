/**
Author: LiXizhi
Company: ParaEngine 
Date: 2013.10.14
Desc: for blurring the background 3d scene to focus on front end UI.  
*/
float2 screenParam = float2(512, 512);
float4x4 colorMatrix;

texture sourceTexture0;
sampler sourceSpl:register(s0) = sampler_state
{
    Texture = <sourceTexture0>;
    MinFilter = Linear;
    MagFilter = Linear;
    AddressU = clamp;
    AddressV = clamp;
};


void FullScreenQuadVS(float3 iPosition:POSITION,
	out float4 oPosition:POSITION,
	inout float2 texCoord:TEXCOORD0)
{
	oPosition = float4(iPosition,1);
	texCoord += 0.5 / screenParam;
}

float4 FilmScratchPS(float2 texCoord:TEXCOORD0):COLOR
{
	float4 color = tex2D(sourceSpl,texCoord);
	float4 dest_color = mul(color,colorMatrix);

	color = lerp(dest_color, color, pow(length((texCoord.xy-0.5)*2), 2));
	return color;
}

technique Default
{
    pass P0
    {
		cullmode = none;
		ZEnable = false;
		ZWriteEnable = false;
		FogEnable = False;
		VertexShader = compile vs_1_1 FullScreenQuadVS();
        PixelShader = compile ps_2_0 FilmScratchPS();
    }
}