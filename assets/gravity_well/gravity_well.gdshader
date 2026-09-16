shader_type canvas_item;
uniform float radius : hint_range(0.0, 0.5) = 0.4;
uniform float softness : hint_range(0.0, 0.2) = 0.01;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 center = vec2(0.5,0.5);
	float dist = distance(UV, center);
	float portal = smoothstep(radius, radius-softness, dist);
	vec3 portal_color = vec3(0.23, 0.35, 0.65);
	COLOR = vec4(portal_color, portal);
	//if ( dist < portal_radius ) {
		//COLOR = portal_color;
	//} else {
		//COLOR = vec4(0.0);
	//}
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
