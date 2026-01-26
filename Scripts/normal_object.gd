## NormalObject
## Base script for objects that are only visible in Normal World (when mask is OFF).
## Usage: Attach to a Node3D and add it to the "normal_only" group in the editor.
extends Node3D
class_name NormalObject

@export var fade_duration: float = 0.2


func _ready() -> void:
	# Add to group for batch operations
	add_to_group("normal_only")
	
	# Connect to GameManager signal
	GameManager.mask_state_changed.connect(_on_mask_state_changed)
	
	# Initialize visibility based on current mask state (visible when mask is OFF)
	_set_visibility_instant(!GameManager.is_mask_on)


func _on_mask_state_changed(is_mask_on: bool) -> void:
	# Show when mask is OFF (normal world)
	_set_visibility_smooth(!is_mask_on)


func _set_visibility_instant(should_show: bool) -> void:
	visible = should_show


func _set_visibility_smooth(should_show: bool) -> void:
	if should_show:
		visible = true
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, fade_duration).from(0.0)
	else:
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, fade_duration)
		await tween.finished
		visible = false
