shader_type spatial;

uniform sampler2D height_map;
uniform sampler2D texture_image;
uniform sampler2D normal_map;
uniform float mesh_size = 1.0;
uniform float strength : hint_range(0.0, 100.0) = 30.0;
uniform float texture_scale = 20.0;

varying vec2 vertex_position;

float height(vec2 pos)
{
	float pixel = texture(height_map, pos).x;
	return (pixel * strength) - strength;
}

void vertex()
{
	vertex_position = (VERTEX.xz / mesh_size) + mesh_size / 8.0;
	float finalHeight = height(vertex_position);
	VERTEX.y += finalHeight;

	float detail = 0.1;
	float normal_x = height(vertex_position - vec2(detail, 0.0)) - height(vertex_position + vec2(detail, 0.0));
	float normal_y = detail;
	float normal_z = height(vertex_position - vec2(0.0, detail)) - height(vertex_position + vec2(0.0, detail));
	
	NORMAL  = normalize(vec3(normal_x, normal_y, normal_z));
}

void fragment()
{
	ALBEDO = texture(texture_image, UV * texture_scale).rgb;
	NORMALMAP = texture(normal_map, UV * texture_scale).xyz * vec3(2.0,2.0,1.0) - vec3(1.0,1.0,0.0);
	NORMALMAP_DEPTH = 1.0;
	
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	RIM = 0.0;
}