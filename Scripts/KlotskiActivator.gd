extends Node3D

@export var interaction_area: InteractionArea
const PUZZLE_ID = "Klotski"

func _ready() -> void:
	if interaction_area:
		interaction_area.interaction_entered.connect(_on_interaction_entered)
		interaction_area.interaction_exited.connect(_on_interaction_exited)
		interaction_area.requires_aim = true # Ensure aim is required if needed
	
	GameManager.fragment_collected.connect(_on_fragment_collected)
	_update_state()

func _update_state() -> void:
	if GameManager.is_puzzle_completed(PUZZLE_ID):
		if interaction_area:
			interaction_area.canInteract = false

func _on_interaction_entered() -> void:
	if not GameManager.is_puzzle_completed(PUZZLE_ID):
		InteractionDot.show_dot()

func _on_interaction_exited() -> void:
	InteractionDot.hide_dot()

func _input(event: InputEvent) -> void:
	if not interaction_area or not interaction_area.canInteract or GameManager.is_puzzle_completed(PUZZLE_ID):
		return
		
	if event.is_action_pressed("interact"):
		# Check aim if required by InteractionArea logic or game design
		if interaction_area.requires_aim:
			var player = get_tree().get_first_node_in_group("PlayerGroup")
			if player and player.last_aimed_interaction != interaction_area:
				return
		
		_on_interact()

func _on_interact() -> void:
	GameManager.request_open_puzzle.emit(PUZZLE_ID)

func _on_fragment_collected(_current: int, _total: int) -> void:
	# Check if THIS puzzle was just completed (assumes logic elsewhere updates state before emitting)
	# Or simply re-check state
	if GameManager.is_puzzle_completed(PUZZLE_ID):
		_update_state()
		InteractionDot.hide_dot()
