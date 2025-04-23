// res://shaders/particle_tint.shader
shader_type canvas_item;

// this is the particle’s texture, made available automatically:
uniform sampler2D texture;

// your tint (pick in the inspector or drive from GDScript)
uniform vec4 tint_color = vec4(1.0, 200.0, 1.0, 1.0);

void fragment() {
    // sample the particle’s sprite
    vec4 tex = texture(texture, UV);
    // multiply by your tint
    COLOR = tex * tint_color;
}