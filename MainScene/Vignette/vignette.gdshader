shader_type canvas_item;

uniform float outerRadius : hint_range(0.0, 5.0) = 1.0;
uniform float MainAlpha : hint_range(0.0, 1.0) = 1.0;
uniform vec4 tintColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float tintIntensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float x = abs(UV.x - 0.5) * 2.0;
	float y = abs(UV.y - 0.5) * 2.0;
	float v = (sqrt((x * x) + (y * y)) / outerRadius);
	
	// Base vignette color (black)
	vec3 vignetteColor = vec3(0.0, 0.0, 0.0);
	
	// Mix with tint color based on intensity
	vec3 finalColor = mix(vignetteColor, tintColor.rgb, tintIntensity);
	
	// Apply vignette effect with tint
	float finalAlpha = max(v * MainAlpha, tintIntensity * 0.4);
	COLOR = vec4(finalColor, finalAlpha);
}