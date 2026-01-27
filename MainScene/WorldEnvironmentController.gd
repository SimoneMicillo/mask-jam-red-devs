## WorldEnvironmentController
## Manages world environment visual changes between Normal and Cursed modes.
## Attach this script to a node in your main scene (or the WorldEnvironment node itself).
extends Node
class_name WorldEnvironmentController

# --- Configuration ---
@export_group("Normal Mode")
@export var normal_fog_enabled: bool = true
@export var normal_fog_color: Color = Color(0.1, 0.15, 0.25)  # Dark blue
@export var normal_fog_density: float = 0.02
@export var normal_ambient_color: Color = Color(0.3, 0.35, 0.5)
@export var normal_ambient_energy: float = 0.5

@export_group("Cursed Mode")
@export var cursed_fog_enabled: bool = true
@export var cursed_fog_color: Color = Color(0.4, 0.05, 0.05)  # Dark red
@export var cursed_fog_density: float = 0.04
@export var cursed_ambient_color: Color = Color(0.6, 0.1, 0.1)
@export var cursed_ambient_energy: float = 0.8

@export_group("Transitions")
@export var transition_duration: float = 0.3

# --- References ---
@onready var world_env: WorldEnvironment = _find_world_environment()
var _current_tween: Tween = null


func _ready() -> void:
	if world_env == null:
		push_error("WorldEnvironmentController: No WorldEnvironment found!")
		return
	
	# Ensure environment resource exists
	if world_env.environment == null:
		world_env.environment = Environment.new()
	
	# Connect to GameManager signal
	GameManager.mask_state_changed.connect(_on_mask_state_changed)
	
	# Initialize to normal mode
	_apply_mode_instant(false)


func _on_mask_state_changed(is_cursed: bool) -> void:
	_apply_mode_smooth(is_cursed)


# --- Private Methods ---

func _find_world_environment() -> WorldEnvironment:
	# First check if we ARE a WorldEnvironment
	#if self is WorldEnvironment:
	#	return self as WorldEnvironment
	
	# Check parent
	var parent: Node = get_parent()
	if parent is WorldEnvironment:
		return parent as WorldEnvironment
	
	# Search siblings
	for sibling: Node in get_parent().get_children():
		if sibling is WorldEnvironment:
			return sibling as WorldEnvironment
	
	# Search entire tree
	return get_tree().get_first_node_in_group("world_environment") as WorldEnvironment


func _apply_mode_instant(is_cursed: bool) -> void:
	if world_env == null or world_env.environment == null:
		return
	
	var env: Environment = world_env.environment
	
	if is_cursed:
		env.fog_enabled = cursed_fog_enabled
		env.fog_light_color = cursed_fog_color
		env.fog_density = cursed_fog_density
		env.ambient_light_color = cursed_ambient_color
		env.ambient_light_energy = cursed_ambient_energy
	else:
		env.fog_enabled = normal_fog_enabled
		env.fog_light_color = normal_fog_color
		env.fog_density = normal_fog_density
		env.ambient_light_color = normal_ambient_color
		env.ambient_light_energy = normal_ambient_energy


func _apply_mode_smooth(is_cursed: bool) -> void:
	if world_env == null or world_env.environment == null:
		return
	
	var env: Environment = world_env.environment
	
	# Cancel any in-progress transition
	if _current_tween != null and _current_tween.is_valid():
		_current_tween.kill()
	
	# Target values
	var target_fog_color: Color
	var target_fog_density: float
	var target_ambient_color: Color
	var target_ambient_energy: float
	
	if is_cursed:
		env.fog_enabled = true  # Enable immediately
		target_fog_color = cursed_fog_color
		target_fog_density = cursed_fog_density
		target_ambient_color = cursed_ambient_color
		target_ambient_energy = cursed_ambient_energy
	else:
		target_fog_color = normal_fog_color
		target_fog_density = normal_fog_density
		target_ambient_color = normal_ambient_color
		target_ambient_energy = normal_ambient_energy
	
	_current_tween = create_tween()
	_current_tween.set_parallel(true)
	_current_tween.set_trans(Tween.TRANS_SINE)
	_current_tween.set_ease(Tween.EASE_IN_OUT)
	
	_current_tween.tween_property(env, "fog_light_color", target_fog_color, transition_duration)
	_current_tween.tween_property(env, "fog_density", target_fog_density, transition_duration)
	_current_tween.tween_property(env, "ambient_light_color", target_ambient_color, transition_duration)
	_current_tween.tween_property(env, "ambient_light_energy", target_ambient_energy, transition_duration)
