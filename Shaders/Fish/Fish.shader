shader_type spatial;

uniform float time_scale = 1.5;
uniform float move  : hint_range(-1.0, 1.0) = 0.25;
uniform float turn  : hint_range(-1.0, 1.0) = 0.25;
uniform float wave  : hint_range(-1.0, 1.0) = 0.50;
uniform float twist : hint_range(-2.0, 2.0) = 1.0;

uniform float mesh_length = 8.0;
uniform float movement_mask_start : hint_range(-1.0, 1.0)  = 0.1;
uniform float movement_mask_end   : hint_range(0.0, 1.0)  = 1.0;

uniform float animation_offset    : hint_range(0.0, 0.5) = 0.1;


varying float mask;
void vertex()
{
	
	float body_depth = ((VERTEX.z +  (mesh_length / 2.0)) / mesh_length);
	float body_depth_mask = smoothstep(movement_mask_start, movement_mask_end, clamp(1.0 - body_depth, 0.0, 1.0));
	mask = body_depth_mask;
	
	float time = (TIME * (animation_offset + INSTANCE_CUSTOM.y) * time_scale) + (6.28318 * INSTANCE_CUSTOM.x);
	
	// Move Left to Right
	VERTEX.x += (cos(time) * move * body_depth_mask);
	
	// Turn Left to Right
	float pivot_angle = cos(time) * turn * body_depth_mask;
	mat2 rotation_matrix = mat2(vec2(cos(pivot_angle), -sin(pivot_angle)), vec2(sin(pivot_angle), cos(pivot_angle)));
	VERTEX.xz = rotation_matrix * VERTEX.xz;
	
	// Body Wave
	float body = (VERTEX.z + 1.0) / 2.0;
	VERTEX.x += cos(time + body) * wave * body_depth_mask;
	
	// Twist Around Center
	float twist_angle = cos(time + body) * 0.3 * twist;
	vec2 twist_matrix_one = vec2(cos(twist_angle), -sin(twist_angle));
	vec2 twist_matrix_two = vec2(sin(twist_angle), cos(twist_angle));
	mat2 twist_matrix = mat2(twist_matrix_one, twist_matrix_two);
	VERTEX.xy = mix(VERTEX.xy, twist_matrix * VERTEX.xy, body_depth_mask);
	
	
}

void fragment()
{
	ALBEDO = vec3(mask);
}








