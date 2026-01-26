## SceneLoader Autoload
## Robust scene transition manager with fade effects.
## Register as Autoload: Project Settings -> Autoload -> SceneLoader
extends Node

# --- Configuration ---
@export var fade_duration: float = 0.5
@export var fade_color: Color = Color.BLACK

# --- State ---
var is_transitioning: bool = false

# --- Internal References ---
var _fade_layer: CanvasLayer = null
var _fade_rect: ColorRect = null


# --- Public API ---

## Change to a new scene with a fade transition.
## Returns immediately; transition happens asynchronously.
func change_scene(path: String) -> void:
	if is_transitioning:
		push_warning("SceneLoader: Already transitioning, ignoring request.")
		return
	
	if not _validate_scene_path(path):
		push_error("SceneLoader: Invalid scene path: " + path)
		return
	
	_perform_transition(path)


## Reload the current scene with a fade transition.
func reload_current_scene() -> void:
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		push_error("SceneLoader: No current scene to reload.")
		return
	
	var scene_path: String = current_scene.scene_file_path
	if scene_path.is_empty():
		push_error("SceneLoader: Current scene has no file path.")
		return
	
	change_scene(scene_path)


# --- Private Methods ---

func _validate_scene_path(path: String) -> bool:
	if path.is_empty():
		return false
	if not ResourceLoader.exists(path):
		return false
	return true


func _perform_transition(path: String) -> void:
	is_transitioning = true
	
	_create_fade_overlay()
	
	# Fade to black
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, fade_duration)
	await tween.finished
	
	# Reset GameManager state on scene change
	if GameManager:
		GameManager.reset_game_state()
	
	# Change scene
	var error: Error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("SceneLoader: Failed to change scene. Error: " + str(error))
		_cleanup_fade_overlay()
		is_transitioning = false
		return
	
	# Wait one frame for scene to initialize
	await get_tree().process_frame
	
	# Fade from black
	var fade_in_tween: Tween = create_tween()
	fade_in_tween.tween_property(_fade_rect, "color:a", 0.0, fade_duration)
	await fade_in_tween.finished
	
	_cleanup_fade_overlay()
	is_transitioning = false


func _create_fade_overlay() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100  # Ensure it's above everything
	_fade_layer.name = "FadeTransitionLayer"
	
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(fade_color.r, fade_color.g, fade_color.b, 0.0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_fade_layer.add_child(_fade_rect)
	get_tree().root.add_child(_fade_layer)


func _cleanup_fade_overlay() -> void:
	if _fade_layer != null:
		_fade_layer.queue_free()
		_fade_layer = null
		_fade_rect = null
