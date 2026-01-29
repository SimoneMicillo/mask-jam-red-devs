extends Node3D

@export var interaction_area: Area3D
@export var return_spawn_node: Node3D

const DIALOGUE_SCENE = preload("res://UI/Shared/dialogue_ui.tscn")

var can_interact: bool = false
var player: Player = null
var is_dialogue_open: bool = false

func _ready() -> void:
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		can_interact = true
		InteractionDot.show_dot()

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		player = null
		can_interact = false
		InteractionDot.hide_dot()

func _input(event: InputEvent) -> void:
	if can_interact and not is_dialogue_open and event.is_action_pressed("interact"):
		start_interaction()

func start_interaction() -> void:
	is_dialogue_open = true
	InteractionDot.hide_dot()
	
	# Instantiate Dialogue UI
	var dialogue_instance = DIALOGUE_SCENE.instantiate()
	get_tree().root.add_child(dialogue_instance)
	
	dialogue_instance.dialogue_finished.connect(_on_dialogue_finished.bind(dialogue_instance))
	
	# Show text
	var message = "Fragment collected.\nThe mask's power can be restored by uniting the fragments."
	dialogue_instance.show_text(message)

func _on_dialogue_finished(dialogue_instance: Node) -> void:
	dialogue_instance.queue_free()
	complete_collection()

func complete_collection() -> void:
	GameManager.collect_fragment("labyrinth_final")
	GameManager.is_mask_locked = false
	GameManager.set_mask_state(false)
	
	if player and return_spawn_node:
		# Add small safety offset
		player.global_position = return_spawn_node.global_position + Vector3(0, 0.5, 0)
		
	# Disable this pedestal logic
	can_interact = false
	interaction_area.queue_free()
	# Optional: visually hide the fragment on the pedestal if there is one
	queue_free()

