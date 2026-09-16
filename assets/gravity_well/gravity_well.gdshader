shader_type canvas_item;
uniform float radius : hint_range(0.0, 0.5) = 0.4;
uniform float rim_width : hint_range(0.0, 0.3) = 0.05;
uniform float softness : hint_range(0.0, 0.2) = 0.01;
uniform vec3 color_inner: source_color = vec3(0.02, 0.04, 0.51);
uniform vec3 color_rim: source_color = vec3(0.23, 0.35, 0.65);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 center = vec2(0.5,0.5);
	float dist = distance(UV, center);
	float mask_outer = smoothstep(radius, radius - softness, dist);
	float mask_inner = smoothstep(radius - rim_width, radius - rim_width - softness, dist);
	float mask_rim = mask_outer - mask_inner;
	vec3 final_color = mask_rim * color_rim + mask_inner * color_inner;
	COLOR = vec4(final_color, mask_outer);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
