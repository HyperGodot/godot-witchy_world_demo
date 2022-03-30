/*========================================================
°                         TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Moon render pass.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================*/
shader_type spatial;
render_mode unshaded;

uniform sampler2D _texture;
uniform vec3 _sun_direction;

float saturate(float v){
	return clamp(v, 0.0, 1.0);
}

varying vec3 normal;
void vertex(){
	normal = (WORLD_MATRIX * vec4(VERTEX, 0.0)).xyz;
}

void fragment(){
	float l = saturate(max(0.0, dot(_sun_direction, normal)) * 2.0);
	ALBEDO = texture(_texture, UV).rgb * l;
}
