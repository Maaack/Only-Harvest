shader_type canvas_item;

uniform float circle_size = 1.1f;
const float RATIO = 16.0/9.0;

void fragment() {
	COLOR.a = step(circle_size, distance(vec2(0.5), vec2(mix(0.5, UV.x, RATIO), UV.y)));
}
