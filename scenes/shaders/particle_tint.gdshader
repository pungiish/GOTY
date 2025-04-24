// res://shaders/particle_tint.gdshader
shader_type canvas_item;

// the particle’s texture (shows up as 'Texture' in the Inspector)
uniform sampler2D texture : source_color;

// your tint (exposed as a color picker)
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 texcol = texture(texture, UV);
    COLOR = texcol * tint_color;
}