shader_type canvas_item;

uniform float squash_stretch_amount : hint_range(0.5, 2.0) = 1.0; // Controls the squash/stretch effect
uniform float time = 0.0; // Used to animate the effect

void fragment() {
    // Calculate the squash/stretch effect
	float squash = sin(time * 10.0) * 0.2 + 1.0; // Oscillates between 0.8 and 1.2
	vec2 scaled_uv = UV;
    
    // Apply squash/stretch to the UV coordinates
	scaled_uv.y = (UV.y - 0.5) * squash + 0.5;
	scaled_uv.x = (UV.x - 0.5) / squash + 0.5;
    
    // Sample the texture with the modified UVs
	vec4 color = texture(TEXTURE, scaled_uv);
    
    // Output the color
	COLOR = color;
}