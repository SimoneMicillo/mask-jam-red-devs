## GameManager Autoload
## Manages global game state: mask toggle, sanity, fragments, and game over logic.
## Register as Autoload: Project Settings -> Autoload -> GameManager
extends Node

# --- Signals ---
signal mask_state_changed(is_active: bool)
signal sanity_changed(new_sanity: float)
signal game_over()
signal fragment_collected(current: int, total: int)
signal all_fragments_collected()
signal request_open_puzzle(puzzle_name: String)
signal klotski_solved() # Emitted when Klotski is solved

func emit_klotski_solved():
	print("DEBUG: GameManager emitting klotski_solved")
	klotski_solved.emit()

# --- Exported Properties ---
@export var max_sanity: float = 100.0
@export var sanity_drain_rate: float = 1.0  # Sanity lost per second when mask is ON

# --- Constants ---
const TOTAL_FRAGMENTS: int = 3

# --- State ---
var current_sanity: float = 100.0
var is_mask_on: bool = false
var _is_game_over: bool = false
var _sanity_drain_paused: bool = false  # Pause drain during QTE
var _fragments_collected: int = 0
var _completed_puzzles: Array[String] = []  # Track which puzzles are done
var is_mask_locked: bool = false # If true, mask cannot be toggled (e.g. cutscenes)
var is_mask_unlocked: bool = false # Player has acquired the mask
var is_mask_on_pedestal: bool = true # Mask is physically on the pedestal

func _ready() -> void:
	reset_game_state()
	# DEBUG: Checking labyrinth trigger
	_fragments_collected = 2


func _process(delta: float) -> void:
	if _is_game_over:
		return
	
	if is_mask_on and not _sanity_drain_paused:
		_drain_sanity(delta)

#func _input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed:
		#if event.keycode == KEY_L:
			#_fragments_collected += 1
			#fragment_collected.emit(_fragments_collected, TOTAL_FRAGMENTS)
			#print("DEBUG: Added fragment. Total: ", _fragments_collected)
		#elif event.keycode == KEY_K:
			#_fragments_collected = max(0, _fragments_collected - 1)
			#fragment_collected.emit(_fragments_collected, TOTAL_FRAGMENTS)
			#print("DEBUG: Removed fragment. Total: ", _fragments_collected)

# --- Public API ---

## Toggle the mask between ON and OFF states.
func toggle_mask() -> void:
	if is_mask_locked or not is_mask_unlocked:
		return
	set_mask_state(!is_mask_on)

## Set the mask to a specific state.
func set_mask_state(active: bool) -> void:
	if is_mask_on == active:
		return
	
	is_mask_on = active
	mask_state_changed.emit(is_mask_on)


## Modify sanity by a given amount (positive or negative).
func modify_sanity(amount: float) -> void:
	if _is_game_over:
		return
	
	current_sanity = clampf(current_sanity + amount, 0.0, max_sanity)
	sanity_changed.emit(current_sanity)
	
	if current_sanity <= 0.0:
		_trigger_game_over()


## Pause or resume sanity drain (used during QTE events)
func set_sanity_drain_paused(paused: bool) -> void:
	_sanity_drain_paused = paused

## Collect a fragment from a puzzle
func collect_fragment(puzzle_id: String) -> void:
	var ui: CanvasLayer = $UI
	if puzzle_id in _completed_puzzles:
		return  # Already collected
	
	_completed_puzzles.append(puzzle_id)
	_fragments_collected += 1
	fragment_collected.emit(_fragments_collected, TOTAL_FRAGMENTS)
	
	
	if _fragments_collected >= TOTAL_FRAGMENTS:
		all_fragments_collected.emit()
		Sounds.get_node("shredsUnited").play()
		# Try to find UI in the current scene safely
		var ui = get_tree().current_scene.find_child("UI", true, false)
		if ui and ui.has_node("GameOver"):
			ui.get_node("GameOver").show()
	else:
		Sounds.get_node("shredobtained").play()


## Check if a puzzle has been completed
func is_puzzle_completed(puzzle_id: String) -> bool:
	return puzzle_id in _completed_puzzles


## Get current fragment count
func get_fragments_collected() -> int:
	return _fragments_collected


## Get total fragments needed
func get_total_fragments() -> int:
	return TOTAL_FRAGMENTS


## Reset all game state for a new game / scene reload.
func reset_game_state() -> void:
	current_sanity = max_sanity
	is_mask_on = false
	_is_game_over = false
	_sanity_drain_paused = false
	_fragments_collected = 0
	# Reset progress flags
	is_mask_unlocked = false
	is_mask_on_pedestal = true
	_completed_puzzles.clear()
	sanity_changed.emit(current_sanity)
	mask_state_changed.emit(is_mask_on)
	fragment_collected.emit(0, TOTAL_FRAGMENTS)


## Check if the game is currently over.
func is_game_over() -> bool:
	return _is_game_over

# --- Private Methods ---

func _drain_sanity(delta: float) -> void:
	modify_sanity(-sanity_drain_rate * delta)

func _trigger_game_over() -> void:
	if _is_game_over:
		return
	
	_is_game_over = true
	set_mask_state(false)  # Turn off mask on death
	game_over.emit()
