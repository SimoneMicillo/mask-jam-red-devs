## GameManager Autoload
## Manages global game state: mask toggle, sanity, and game over logic.
## Register as Autoload: Project Settings -> Autoload -> GameManager
extends Node

# --- Signals ---
signal mask_state_changed(is_active: bool)
signal sanity_changed(new_sanity: float)
signal game_over()

# --- Exported Properties ---
@export var max_sanity: float = 100.0
@export var sanity_drain_rate: float = 5.0  # Sanity lost per second when mask is ON

# --- State ---
var current_sanity: float = 100.0
var is_mask_on: bool = false
var _is_game_over: bool = false
var _sanity_drain_paused: bool = false  # Pause drain during QTE


func _ready() -> void:
	reset_game_state()


func _process(delta: float) -> void:
	if _is_game_over:
		return
	
	if is_mask_on and not _sanity_drain_paused:
		_drain_sanity(delta)


# --- Public API ---

## Toggle the mask between ON and OFF states.
func toggle_mask() -> void:
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


## Reset all game state for a new game / scene reload.
func reset_game_state() -> void:
	current_sanity = max_sanity
	is_mask_on = false
	_is_game_over = false
	_sanity_drain_paused = false
	sanity_changed.emit(current_sanity)
	mask_state_changed.emit(is_mask_on)


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

