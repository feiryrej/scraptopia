shader_type canvas_item;

uniform float shake_intensity = 0.0;
uniform float shake_speed = 1.0;

// Pseudo-random function to generate random values
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
    vec2 shake = vec2(0.0);

    // Apply shaking only to vertices with negative y-coordinates
    if (VERTEX.y < 0.0) {
        // Calculate the current and next random seeds
        float current_time = TIME * shake_speed;
        float current_seed = floor(current_time);
        float next_seed = current_seed + 1.0;

        // Generate random values for the current and next seeds
        float random_current = rand(vec2(VERTEX.x, current_seed));
        float random_next = rand(vec2(VERTEX.x, next_seed));

        // Smoothly interpolate between the current and next random values
        float t = fract(current_time); // Fractional part of the time
        float random_seed = mix(random_current, random_next, t);

        // Calculate randomized shake
        shake.x = sin(TIME * shake_speed + VERTEX.y + random_seed * 6.2831) * shake_intensity;
    }

    // Apply the shake to the vertex position
    VERTEX.xy += shake;
}