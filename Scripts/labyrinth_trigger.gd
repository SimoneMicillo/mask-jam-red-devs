extends Area3D

@export var labyrinth_spawn_node: Node3D
@export var fragments_required: int = 2

var player: Player = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		print("DEBUG: LabyrinthTrigger: Player ENTERED trigger area.")
		player = body

func _on_body_exited(body: Node3D) -> void:
	if body is Player and body == player:
		print("DEBUG: LabyrinthTrigger: Player EXITED trigger area.")
		player = null

func _process(_delta: float) -> void:
	if player:
		# print("DEBUG: LabyrinthTrigger check - Mask: ", GameManager.is_mask_on, " Fragments: ", GameManager.get_fragments_collected())
		if GameManager.is_mask_on and GameManager.get_fragments_collected() >= fragments_required:
			print("DEBUG: LabyrinthTrigger: Condition MET. Teleporting...")
			trigger_teleport()

func trigger_teleport() -> void:
	if not labyrinth_spawn_node:
		print("ERROR: Labyrinth Spawn Node not assigned in LabyrinthTrigger!")
		return
		
	print("DEBUG: Teleporting player to: ", labyrinth_spawn_node.global_position)
	GameManager.is_mask_locked = true
	
	# Add slight vertical offset to prevent sticking in floor
	player.global_position = labyrinth_spawn_node.global_position + Vector3(0, 0.5, 0)
	
	# Optional: Reset player velocity or state if needed
	if player.has_method("set_velocity"):
		player.velocity = Vector3.ZERO

