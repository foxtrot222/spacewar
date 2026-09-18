shader_type canvas_item;
uniform float m1: hint_range(0.0, 1.0);
uniform float m2: hint_range(0.0, 1.0);
uniform float m3: hint_range(0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	if ( dist < m3 ) {
		COLOR.rgb = vec3(1.0);
	}
	else if (dist < m2 ) {
		COLOR.rgb = vec3(0.9);
	}
	else if ( dist < m1 ) {
		COLOR.rgb = vec3(0.7);
	} else {
		COLOR = vec4(0.0);
	}
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
