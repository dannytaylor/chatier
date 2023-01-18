shader_type spatial;
render_mode unshaded;//, cull_disabled;
uniform vec4 modulate : source_color;
uniform sampler2D overlay : source_color;
uniform sampler2D texture_albedo : source_color;

void fragment() {
	vec2 base_uv = SCREEN_UV;
	vec4 view = texture(texture_albedo, base_uv);
	
	vec2 outline_uv = UV;
	vec4 outline = texture(overlay, outline_uv);
	
	if(outline.rgb == vec3(1.0, 0.0, 0.0)){
		ALBEDO = view.rgb;
	}else{
		ALBEDO = outline.rgb * modulate.rgb;
		ALPHA = outline.a;
	}

	//ALBEDO = view.rgb;
}