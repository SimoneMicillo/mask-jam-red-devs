## VignetteController
## Controls the vignette shader's red tint effect based on mask/curse mode.
## Attach this script to the vignette TextureRect node in the UI.
extends TextureRect


@export var curse_tint_color: Color = Color(0.8, 0.1, 0.1, 1.0)  # Red tint
@export var curse_tint_intensity: float = 0.5
@export var transition_duration: float = 0.3

var _shader_material: ShaderMaterial

func _ready() -> void:
	_shader_material = material as ShaderMaterial
	
	if _shader_material == null:
		push_error("VignetteController: No ShaderMaterial found on this node!")
		return
	
	# Connect to GameManager signal
	GameManager.mask_state_changed.connect(_on_mask_state_changed)
	
	# Initialize to normal state
	_set_curse_effect(false)


func _on_mask_state_changed(is_cursed: bool) -> void:
	_set_curse_effect(is_cursed)


func _set_curse_effect(enabled: bool) -> void:
	if _shader_material == null:
		return
	
	var target_intensity: float = curse_tint_intensity if enabled else 0.0
	
	# Set the tint color (always red, just change intensity)
	_shader_material.set_shader_parameter("tintColor", curse_tint_color)
	
	# Animate the tint intensity
	var tween: Tween = create_tween()
	tween.tween_method(_set_tint_intensity, _get_current_intensity(), target_intensity, transition_duration)


func _set_tint_intensity(value: float) -> void:
	if _shader_material:
		_shader_material.set_shader_parameter("tintIntensity", value)


func _get_current_intensity() -> float:
	if _shader_material:
		var current = _shader_material.get_shader_parameter("tintIntensity")
		return current if current != null else 0.0
	return 0.0
