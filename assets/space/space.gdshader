shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 size = TEXTURE_PIXEL_SIZE;
	vec4 left = texture(TEXTURE, UV + vec2(-size.x, 0.0));
	vec4 right = texture(TEXTURE, UV + vec2(size.x, 0.0));
	vec4 top = texture(TEXTURE, UV + vec2(0.0, -size.y));
	vec4 bottom = texture(TEXTURE, UV + vec2(0.0, size.y));
	vec4 current = texture(TEXTURE, UV);
	COLOR = max(current, max(left, max(right,  max(top, bottom))));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
