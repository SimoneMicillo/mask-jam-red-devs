## Puzzle Trigger
## Area3D that triggers the Klotski puzzle when player interacts with it
extends Area3D
class_name PuzzleTrigger

signal puzzle_triggered()

@export var puzzle_id: String = "klotski_1"  # Must match puzzle's puzzle_id
@export var interaction_prompt: String = "Premi [E] per interagire"
@export var requires_mask: bool = true  # Only visible/interactable with mask on

var _player_in_range: bool = false
var _is_solved: bool = false

@onready var prompt_label: Label3D = $PromptLabel
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Check if already completed from previous session/attempt
	_is_solved = GameManager.is_puzzle_completed(puzzle_id)
	
	# Connect to mask state if requires_mask
	if requires_mask:
		GameManager.mask_state_changed.connect(_on_mask_state_changed)
		_update_visibility()
	
	if prompt_label:
		prompt_label.visible = false
		if _is_solved:
			prompt_label.text = "RISOLTO!"
			prompt_label.modulate = Color(0.2, 1.0, 0.2)
	
	if _is_solved and mesh:
		mesh.transparency = 0.8

func _process(_delta: float) -> void:
	if _is_solved:
		return
	
	if _player_in_range and Input.is_action_just_pressed("interact"):
		_trigger_puzzle()

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_player_in_range = true
		if prompt_label and _should_be_visible():
			prompt_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_player_in_range = false
		if prompt_label:
			prompt_label.visible = false

func _on_mask_state_changed(_is_active: bool) -> void:
	_update_visibility()
	if prompt_label:
		prompt_label.visible = _player_in_range and _should_be_visible()

func _should_be_visible() -> bool:
	if _is_solved:
		return true  # Always show if solved
	if requires_mask:
		return GameManager.is_mask_on
	return true

func _update_visibility() -> void:
	if mesh:
		if _is_solved:
			mesh.visible = true
			mesh.transparency = 0.8
		else:
			mesh.visible = _should_be_visible()

func _trigger_puzzle() -> void:
	if _is_solved:
		return
	
	# Find and open the puzzle
	var klotski = get_tree().get_first_node_in_group("klotski_puzzle")
	if klotski == null:
		var puzzles = get_tree().root.find_children("*", "KlotskiPuzzle", true, false)
		if puzzles.size() > 0:
			klotski = puzzles[0]
	
	if klotski != null and klotski.has_method("open_puzzle"):
		klotski.puzzle_completed.connect(_on_puzzle_completed, CONNECT_ONE_SHOT)
		klotski.open_puzzle()
		puzzle_triggered.emit()

func _on_puzzle_completed() -> void:
	_is_solved = true
	if prompt_label:
		prompt_label.text = "RISOLTO!"
		prompt_label.modulate = Color(0.2, 1.0, 0.2)
	
	if mesh:
		var tween = create_tween()
		tween.tween_property(mesh, "transparency", 0.8, 1.0)

