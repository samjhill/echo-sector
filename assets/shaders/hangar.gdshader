shader_type canvas_item;

uniform vec2 uv_offset = vec2(0.0, 0.0);

void fragment() {
	vec2 uv = UV + uv_offset;
	COLOR = texture(TEXTURE, uv);
}
