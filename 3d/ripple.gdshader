
shader_type spatial;

uniform vec2 center = vec2(0.5,1.2);
uniform float speed = 0.30;

void fragment()
{
	vec3 iResolution = 1.0/vec3(1.0,2.4,1.0);
    float invAr = 1.4 * iResolution.y / iResolution.x;

    vec2 uv = UV / iResolution.xy;
		
	vec3 col = vec4(uv,0.5+0.5*sin(TIME),1.0).xyz*speed;
   
    vec3 texcol;
			
	float x = (center.x-uv.x);
	float y = (center.y-uv.y) *invAr;
		
	//float r = -sqrt(x*x + y*y); //uncoment this line to symmetric ripples
	float r = -(x*x + y*y);
	float z = 1.0 + 0.5*sin((r+TIME*speed)/0.03);
	
	texcol.x = z;
	texcol.y = z;
	texcol.z = z;
	
	ALBEDO = vec3(col*texcol);
	NORMAL = vec3(col*texcol);
	SPECULAR = 0.7;
	ROUGHNESS = 0.2;
	METALLIC = 0.7;
}


