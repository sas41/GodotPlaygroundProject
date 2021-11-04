shader_type spatial;
render_mode specular_schlick_ggx, world_vertex_coords;
//render_mode specular_toon, world_vertex_coords;

uniform vec4 color       : hint_color = vec4(0.25, 0.85, 1.0, 1.0);

uniform sampler2D foam_texture;

uniform float murkiness  : hint_range(0.0, 1.0) = 0.15;
uniform float softness   : hint_range(0.0, 1.0) = 0.8;
uniform float refraction : hint_range(0.0, 0.05) = 0.03;

uniform float metalic    : hint_range(0.0, 1.0) = 0.8;
uniform float roughness  : hint_range(0.0, 1.0) = 0.2;
uniform float rim        : hint_range(0.0, 1.0) = 0.0;

uniform float geometric_wave_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float geometric_wave_density   : hint_range(0.1, 10.0) = 1.0;
uniform float geometric_wave_angle     : hint_range(0.0, 180.0) = 66.0;
uniform float geometric_wave_speed     : hint_range(-1.0, 1.0) = 0.5;

uniform sampler2D detail_texture;
uniform float detail_texture_intensity : hint_range(0.0, 1.0) = 0.2;
uniform float detail_texture_speed_x   : hint_range(-1.0, 1.0) = 0.1;
uniform float detail_texture_speed_z   : hint_range(-1.0, 1.0) = 0.1;

uniform sampler2D wave_texture;
uniform float wave_texture_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float wave_texture_speed_x   : hint_range(-1.0, 1.0) = -0.1;
uniform float wave_texture_speed_z   : hint_range(-1.0, 1.0) = -0.1;

varying vec2 vertex_position;

float geometricWaveHeight(vec2 position, float time)
{
	float co = cos(radians(geometric_wave_angle));
	float si = sin(radians(geometric_wave_angle));
	
	float x = geometric_wave_density * co;
	float y = geometric_wave_density * si;
	
	float wave = (position.x * x) + (position.y * y) + (time * geometric_wave_speed);
	
	float height = cos(wave) * geometric_wave_intensity;
	return height;
}

float textureHeight(vec2 position, float time, sampler2D tex, float tex_intensity, float tex_speed_x, float tex_speed_z)
{
	// Calculate an offset, based on time, x and z movement direction and speed.
	// Apply offset to displacement position.
	// This makes it look like it's moving.
	vec2 offset = vec2(time * tex_speed_x, time * tex_speed_z);
	position = position - offset;
	
	// Get the corresponding pixel's color from the noise texture.
	// Color's brightness is the height.
	float height = texture(tex, position).x;
	
	// Multiply Height w/ calm, to tone it down.
	height = height * tex_intensity;
	
	// Push height down by 1/4th of calm.
	// This way, mesh is not too displaced.
	height = height - (tex_intensity / 4.0);
	
	return height;
}

vec3 calculateNormal(vec2 position, float time)
{
	// Recalculate Normal to fix shading.
	float variation = 0.1;
	
	vec2 x_normal_vector = position + vec2(variation, 0.0);
	
	float x_geoWave = geometricWaveHeight(x_normal_vector, time);
	float x_texDetail = textureHeight(x_normal_vector, time, detail_texture, detail_texture_intensity, detail_texture_speed_x, detail_texture_speed_z);
	float x_texWave = textureHeight(x_normal_vector, time, wave_texture, wave_texture_intensity, wave_texture_speed_x, wave_texture_speed_z);
	float x_component = (x_geoWave + x_texDetail + x_texWave ) /3.0;
	
	float y_component = variation;
	
	vec2 z_normal_vector = position + vec2(0.0, variation);
	float z_geoWave = geometricWaveHeight(z_normal_vector, time);
	float z_texDetail = textureHeight(z_normal_vector, time, detail_texture, detail_texture_intensity, detail_texture_speed_x, detail_texture_speed_z);
	float z_texWave = textureHeight(z_normal_vector, time, wave_texture, wave_texture_intensity, wave_texture_speed_x, wave_texture_speed_z);
	float z_component = (x_geoWave + x_texDetail + x_texWave ) /3.0;
	
	return normalize(vec3(x_component, y_component, z_component));
}

void vertex()
{
	vertex_position = VERTEX.xz / 2.0;
	
	float geoWave = geometricWaveHeight(vertex_position, TIME);
	float texDetail = textureHeight(vertex_position, TIME, detail_texture, detail_texture_intensity, detail_texture_speed_x, detail_texture_speed_z);
	float texWave = textureHeight(vertex_position, TIME, wave_texture, wave_texture_intensity, wave_texture_speed_x, wave_texture_speed_z);
	
	float height = (geoWave + texDetail + texWave) / 3.0;
	
	VERTEX.y += height;
	
	NORMAL = calculateNormal(vertex_position, TIME);
}

void fragment()
{
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	
	ALBEDO = color.rgb + (0.1 * fresnel);
	
	METALLIC = metalic;
	ROUGHNESS = roughness * (1.0 - fresnel);
	RIM = rim;
	
	
	
	
	
	// Calculate Depth:
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x; // Get depth for the current fragment.
	depth = (depth * 2.0) -1.0;                        // Scale it between -1.0 and 1.0.
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]); // Magic from the internet.
	depth = depth + VERTEX.z;                          // Add the VERTEX Z buffer.
	
	
	// The ALPHA is determined by the depth of the object behind each fragment, inversed.
	// It's capped between inverse of the softness value and alpha of the color.
	float alpha_depth = exp(-depth * murkiness);       // Negate, multiply by murkiness and exponantiate.
	ALPHA = clamp(1.0 - alpha_depth, 1.0 - softness, color.a);
	
	// TODO: FOAM
	//float blend_ratio = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	//blend_ratio = (depth * 2.0) -1.0;
	//ALBEDO = ((ALBEDO) + ((texture(foam_texture, UV).rgb) * blend_ratio)) / 2.0;
	
	
	//vec3 ref_normal = normalize( mix(NORMAL,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + NORMAL * NORMALMAP.z,NORMALMAP_DEPTH) );
	//vec2 ref_ofs = SCREEN_UV - ref_normal.xy * refraction;
	//EMISSION += textureLod(SCREEN_TEXTURE,ref_ofs,ROUGHNESS * 2.0).rgb * (1.0 - ALPHA);
	
	//ALBEDO *= ALPHA;
	//ALPHA = 1.0;
	
	// TODO: Fix Refractions
	/*float refraction_depth = exp2(-depth);
	refraction_depth = clamp(refraction_depth, 0.0, 1.0);
	vec2 offset = SCREEN_UV + (NORMAL.xy * 0.1  * (1.0 - refraction_depth));
	EMISSION += textureLod(SCREEN_TEXTURE, offset, 0.0).rgb * (1.0 - ALPHA);
	ALBEDO *= ALPHA;
	ALPHA = 1.0;*/
}