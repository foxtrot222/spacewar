shader_type canvas_item;

uniform float radius : hint_range(0.0, 0.5) = 0.4;
uniform float rim_width : hint_range(0.0, 0.3) = 0.05;
uniform float softness : hint_range(0.0, 0.2) = 0.01;
uniform vec3 color_inner: source_color = vec3(0.02, 0.04, 0.51);
uniform vec3 color_rim: source_color = vec3(0.23, 0.35, 0.65);
uniform float breathing_strength: hint_range(0.0, 0.1, 0.001) = 0.02;
uniform float displacement_strength: hint_range(0.0, 0.2) = 0.05;
uniform vec2 noise_direction = vec2(1.0, 1.0);
uniform float noise_speed: hint_range(0.0, 1.0) = 0.1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 center = vec2(0.5,0.5);
	vec2 sample_uv = UV + TIME * noise_direction * noise_speed;
	float noise_displacement = texture(TEXTURE, sample_uv).r;
	float oscillation = sin(TIME);
	float dist = distance(UV, center) + noise_displacement * displacement_strength + oscillation * breathing_strength;
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
