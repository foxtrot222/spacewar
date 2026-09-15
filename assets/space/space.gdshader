shader_type canvas_item;
uniform float twink_factor = 5.0;
uniform int twink_cood = 25;

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
	vec4 final = max(current, max(left, max(right,  max(top, bottom))));
	if (final.rgb == vec3(1.0)) {
		if ( int((UV / size).y) % twink_cood == 0 ) {
			COLOR.rgb = abs(vec3(sin(TIME*twink_factor + TAU * length(UV/size))));
		} else {
			COLOR.rgb = vec3(1.0);
		}
		
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
