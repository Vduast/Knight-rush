shader_type canvas_item;

uniform float light_influence : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    // COLOR es el resultado de la luz en Godot
    COLOR = mix(tex_color, COLOR, light_influence);
}