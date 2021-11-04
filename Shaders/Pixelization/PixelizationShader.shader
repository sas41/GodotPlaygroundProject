shader_type canvas_item;
//render_mode unshaded;

uniform float pixel_size : hint_range(1.0, 999999.0) = 3.0;
uniform float blur : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	if (pixel_size != 1.0) {
		float newX = SCREEN_PIXEL_SIZE.x * pixel_size;
		float newY = SCREEN_PIXEL_SIZE.y * pixel_size;
		
		vec2 new_scren_uv = SCREEN_UV;
		new_scren_uv -= mod(new_scren_uv, vec2(newX, newY)) - (SCREEN_PIXEL_SIZE * 2.0);
		COLOR.rgb = textureLod(SCREEN_TEXTURE, new_scren_uv, blur).rgb;
	}
	else {
		COLOR.a = 0.0;
	}
}
