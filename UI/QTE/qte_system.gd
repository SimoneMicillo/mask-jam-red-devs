## QTE System
## Manages Quick Time Event sequences with multiple key prompts
## Supports both regular QTE and demon attack QTE
extends CanvasLayer
class_name QTESystem

signal qte_completed(failed_count: int)

# QTE Configuration
const KEYS_TO_USE := ["Q", "E", "R", "T", "Y", "U", "I", "O", "P", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M"]
const KEY_SEQUENCE := [
	{"time": 3.0},  # First key: 3 seconds
	{"time": 2.0},  # Second key: 2 seconds
	{"time": 1.0}   # Third key: 1 second
]

# Demon attack configuration - 3 attacks, faster timing
const DEMON_KEY_SEQUENCE := [
	{"time": 2.0},  # First attack
	{"time": 1.5},  # Second attack
	{"time": 1.0}   # Third attack
]

@export var sanity_loss_per_fail: float = 10.0
@export var health_loss_per_demon_attack: float = 5.0  # 5% vita per attacco

# State
var _is_active: bool = false
var _current_key_index: int = 0
var _failed_keys_count: int = 0
var _player_reference: Node = null
var _used_keys: Array[String] = []
var _waiting_feedback: bool = false  # BLOCK timer during feedback
var _is_demon_mode: bool = false  # True when demon is attacking
var _demon_damage_per_fail: float = 5.0

# UI References
@onready var overlay: ColorRect = $Overlay
@onready var qte_panel: Panel = $QTEPanel
@onready var key_display_container: VBoxContainer = $QTEPanel/MarginContainer/VBoxContainer/KeyDisplayContainer
@onready var key_label: Label = $QTEPanel/MarginContainer/VBoxContainer/KeyDisplayContainer/KeyLabel
@onready var timer_label: Label = $QTEPanel/MarginContainer/VBoxContainer/KeyDisplayContainer/TimerLabel
@onready var progress_bar: ProgressBar = $QTEPanel/MarginContainer/VBoxContainer/ProgressBar
@onready var instruction_label: Label = $QTEPanel/MarginContainer/VBoxContainer/InstructionLabel
@onready var sequence_label: Label = $QTEPanel/MarginContainer/VBoxContainer/SequenceLabel
@onready var title_label: Label = $QTEPanel/MarginContainer/VBoxContainer/TitleLabel

# Timer for key prompt
var _current_key: String = ""
var _time_limit: float = 0.0
var _remaining_time: float = 0.0

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_find_player()

func _show() -> void:
	show()
	_is_active = true

func _hide() -> void:
	hide()
	_is_active = false

func _find_player() -> void:
	await get_tree().process_frame
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node == null:
		var players_array = get_tree().root.find_children("*", "Player", true, false)
		if players_array.size() > 0:
			player_node = players_array[0]
	_player_reference = player_node

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		# Debug trigger: Backtick key
		if event.keycode == KEY_SECTION:
			if not _is_active:
				start_qte()
			return
		
		if _is_active:
			var pressed_key: String = OS.get_keycode_string(event.keycode)
			if event.keycode == KEY_ESCAPE:
				return
			_check_key_input(pressed_key)

func _process(delta: float) -> void:
	if not _is_active or _waiting_feedback:
		return
	_remaining_time -= delta
	_update_timer_display()
	if _remaining_time <= 0.0:
		_fail_current_key()

func start_qte() -> void:
	if _is_active:
		return
	_is_demon_mode = false
	_is_active = true
	_current_key_index = 0
	_failed_keys_count = 0
	_used_keys.clear()
	visible = true
	_set_player_input_enabled(false)
	_update_title()
	_show_next_key()

## Start a demon attack QTE - 3 attacks, each failed attack = health damage
func start_demon_qte(damage_per_attack: float = 5.0) -> void:
	if _is_active:
		return
	_is_demon_mode = true
	_demon_damage_per_fail = damage_per_attack
	_is_active = true
	_current_key_index = 0
	_failed_keys_count = 0
	_used_keys.clear()
	visible = true
	_set_player_input_enabled(false)
	_update_title()
	_show_next_key()

func _update_title() -> void:
	if title_label != null:
		if _is_demon_mode:
			title_label.text = "DEMON ATTACK!"
			title_label.modulate = Color(1.0, 0.1, 0.1)
		else:
			title_label.text = "QUICK TIME EVENT"
			title_label.modulate = Color(1.0, 0.3, 0.3)

func _show_next_key() -> void:
	var current_sequence = DEMON_KEY_SEQUENCE if _is_demon_mode else KEY_SEQUENCE
	
	if _current_key_index >= current_sequence.size():
		_complete_qte()
		return
	
	_current_key = _get_random_unused_key()
	_used_keys.append(_current_key)
	
	_time_limit = current_sequence[_current_key_index]["time"]
	_remaining_time = _time_limit
	
	key_label.text = _get_readable_key_name(_current_key)
	
	if _is_demon_mode:
		instruction_label.text = "DODGE THE ATTACK!"
		sequence_label.text = "Attack %d / %d" % [_current_key_index + 1, current_sequence.size()]
	else:
		instruction_label.text = "Press the key!"
		sequence_label.text = "Key %d / %d" % [_current_key_index + 1, current_sequence.size()]
	
	progress_bar.max_value = _time_limit
	progress_bar.value = _time_limit
	_update_timer_display()

func _check_key_input(pressed_key: String) -> void:
	if pressed_key == _current_key:
		_success_current_key()
	# Wrong keys are ignored, only timeout counts as fail

func _success_current_key() -> void:
	_waiting_feedback = true
	_show_feedback("✓ SUCCESS!", Color(0.2, 1.0, 0.2))
	await get_tree().create_timer(0.3).timeout
	_current_key_index += 1
	_waiting_feedback = false
	_show_next_key()

func _fail_current_key() -> void:
	_waiting_feedback = true
	_failed_keys_count += 1
	
	if _is_demon_mode:
		# Demon attack - damage health and shake camera
		GameManager.modify_sanity(-_demon_damage_per_fail)
		_trigger_camera_shake()
		_show_feedback("✗ HIT! -%.0f%% HP" % _demon_damage_per_fail, Color(1.0, 0.0, 0.0))
	else:
		GameManager.modify_sanity(-sanity_loss_per_fail)
		_show_feedback("✗ FAILED!", Color(1.0, 0.2, 0.2))
	
	await get_tree().create_timer(0.5).timeout
	_current_key_index += 1
	_waiting_feedback = false
	_show_next_key()

func _trigger_camera_shake() -> void:
	if _player_reference == null:
		_find_player()
	if _player_reference != null:
		var camera_comp = _player_reference.get_node_or_null("CameraComponent")
		if camera_comp != null and camera_comp.has_method("shake"):
			camera_comp.shake(0.4, 20.0)

func _complete_qte() -> void:
	_is_active = false
	if _failed_keys_count == 0:
		if _is_demon_mode:
			_show_feedback("PERFECT DODGE!", Color(0.2, 1.0, 0.2))
		else:
			_show_feedback("PERFECT!", Color(0.2, 1.0, 0.2))
	else:
		if _is_demon_mode:
			var total_damage = _failed_keys_count * _demon_damage_per_fail
			_show_feedback("SURVIVED!\n-%.0f%% HP" % total_damage, Color(1.0, 0.5, 0.2))
		else:
			_show_feedback("QTE Complete\n%d Failed" % _failed_keys_count, Color(1.0, 0.8, 0.2))
	await get_tree().create_timer(1.5).timeout
	visible = false
	_set_player_input_enabled(true)
	_is_demon_mode = false
	qte_completed.emit(_failed_keys_count)

func _show_feedback(text: String, color: Color) -> void:
	instruction_label.text = text
	instruction_label.modulate = color
	key_label.visible = false
	timer_label.visible = false
	progress_bar.visible = false
	await get_tree().create_timer(0.1).timeout
	key_label.visible = true
	timer_label.visible = true
	progress_bar.visible = true

func _update_timer_display() -> void:
	timer_label.text = "%.1f s" % max(_remaining_time, 0.0)
	progress_bar.value = _remaining_time
	if _remaining_time <= 1.0:
		timer_label.modulate = Color(1.0, 0.2, 0.2)
		progress_bar.modulate = Color(1.0, 0.2, 0.2)
	elif _remaining_time <= 2.0:
		timer_label.modulate = Color(1.0, 0.8, 0.2)
		progress_bar.modulate = Color(1.0, 0.8, 0.2)
	else:
		timer_label.modulate = Color(0.2, 1.0, 0.2)
		progress_bar.modulate = Color(0.2, 1.0, 0.2)

func _get_random_unused_key() -> String:
	var available_keys := KEYS_TO_USE.duplicate()
	for used_key in _used_keys:
		available_keys.erase(used_key)
	if available_keys.is_empty():
		available_keys = KEYS_TO_USE.duplicate()
	return available_keys[randi() % available_keys.size()]

func _get_readable_key_name(keycode_string: String) -> String:
	if keycode_string == "Space":
		return "SPACE"
	return keycode_string

func _set_player_input_enabled(enabled: bool) -> void:
	if _player_reference == null:
		_find_player()
	if _player_reference != null:
		_player_reference.set_physics_process(enabled)
		if not enabled and _player_reference.has_method("set") and "velocity" in _player_reference:
			_player_reference.velocity = Vector3.ZERO
