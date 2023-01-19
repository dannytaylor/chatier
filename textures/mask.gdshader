shader_type canvas_item;

uniform sampler2D mask;

void fragment() {
	COLOR = texture(TEXTURE,UV);
	
	vec2 muv = UV;
	
	COLOR.a = texture(mask,muv).r;
	
}
