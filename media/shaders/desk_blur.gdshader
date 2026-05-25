shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 10.0) = 0.0;
uniform float mix_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 color_over : source_color = vec4(1.0);

void fragment() {
	vec4 screen_col = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);

	float gray = dot(screen_col.rgb, vec3(0.299, 0.587, 0.114));
	vec4 grayscale = vec4(vec3(gray), screen_col.a);

	vec4 fin = mix(grayscale, color_over, mix_amount);

	// If this shader is on a Sprite2D / TextureRect and you want to keep its shape:
	vec4 mask = texture(TEXTURE, UV);
	COLOR = vec4(fin.rgb, fin.a * mask.a);

	// If this is on a full ColorRect instead, use this instead:
	// COLOR = fin;
}