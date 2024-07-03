shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform vec4 color: source_color;
uniform float multiplier = 0.2;
uniform float softness = 2;
void fragment() {
	float value = distance(UV,vec2(0.5));
	COLOR = vec4(color.rgb,smoothstep(multiplier,softness,value));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
