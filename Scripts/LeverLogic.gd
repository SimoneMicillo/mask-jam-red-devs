extends Node
class_name LeverLogic

signal activated

@export var mesh_instance: MeshInstance3D
@export var interaction_area: InteractionArea

var is_activated: bool = false
var visible_only_masked: bool = false
var visible_only_normal: bool = false
var is_force_hidden: bool = false # Managed by puzzle logic (e.g. locked state)

func _ready() -> void:
	if interaction_area:
		interaction_area.interaction_entered.connect(_on_interaction_entered)
		interaction_area.interaction_exited.connect(_on_interaction_exited)
		interaction_area.requires_aim = true # Force aim requirement
	
	GameManager.mask_state_changed.connect(_on_mask_state_changed)
	_update_visibility()

func set_visible_only_masked(only_masked: bool) -> void:
	visible_only_masked = only_masked
	_update_visibility()

func set_visible_only_normal(only_normal: bool) -> void:
	visible_only_normal = only_normal
	_update_visibility()

func set_force_hidden(force_hide: bool) -> void:
	is_force_hidden = force_hide
	_update_visibility()

func show_lever() -> void:
	if mesh_instance: mesh_instance.show()
	if interaction_area: interaction_area.canInteract = true

func hide_lever() -> void:
	if mesh_instance: mesh_instance.hide()
	if interaction_area: interaction_area.canInteract = false

func _update_visibility() -> void:
	if is_activated: return # Keep state if activated
	
	if is_force_hidden:
		hide_lever()
		return
	
	if visible_only_masked:
		if GameManager.is_mask_on:
			show_lever()
		else:
			hide_lever()
	elif visible_only_normal:
		if not GameManager.is_mask_on:
			show_lever()
		else:
			hide_lever()
	else:
		show_lever()

func _on_mask_state_changed(_is_on: bool) -> void:
	if visible_only_masked or visible_only_normal:
		_update_visibility()

func _on_interaction_entered() -> void:
	if not is_activated:
		InteractionDot.show_dot()

func _on_interaction_exited() -> void:
	InteractionDot.hide_dot()

func _input(event: InputEvent) -> void:
	if not interaction_area or not interaction_area.canInteract:
		return
		
	if is_activated: return

	if event.is_action_pressed("interact"):
		if interaction_area.requires_aim:
			# Extra check: Player must be aiming at THIS interaction
			var player = get_tree().get_first_node_in_group("PlayerGroup")
			if player and player.last_aimed_interaction != interaction_area:
				return 
				
		activate()

func activate() -> void:
	is_activated = true
	interaction_area.canInteract = false
	InteractionDot.hide_dot()
	
	# Rotate 180 degrees
	if mesh_instance:
		var tween = get_tree().create_tween()
		tween.tween_property(mesh_instance, "rotation_degrees:x", 180.0, 0.5).as_relative().set_trans(Tween.TRANS_BOUNCE)
	
	activated.emit()
