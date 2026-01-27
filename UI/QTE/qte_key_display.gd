## QTE Key Display
## Displays a single key prompt with countdown timer
extends Control
class_name QTEKeyDisplay

signal key_pressed_correct()
signal key_failed()

@export var key_to_press: String = ""
@export var time_limit: float = 3.0

@onready var key_label: Label = $KeyLabel
@onready var timer_label: Label = $TimerLabel
@onready var progress_bar: ProgressBar = $ProgressBar

var _remaining_time: float = 0.0
var _is_active: bool = false


func _ready() -> void:
	visible = false
	_is_active = false


func start_prompt(key: String, duration: float) -> void:
	key_to_press = key
	time_limit = duration
	_remaining_time = duration
	_is_active = true
	visible = true
	
	# Display the key name
	key_label.text = _get_readable_key_name(key)
	
	# Setup progress bar
	progress_bar.max_value = duration
	progress_bar.value = duration
	
	_update_timer_display()


func _process(delta: float) -> void:
	if not _is_active:
		return
	
	_remaining_time -= delta
	progress_bar.value = _remaining_time
	_update_timer_display()
	
	# Check if time ran out
	if _remaining_time <= 0.0:
		_fail_prompt()


func _input(event: InputEvent) -> void:
	if not _is_active:
		return
	
	# Check if the correct key was pressed
	if event is InputEventKey and event.pressed and not event.echo:
		var pressed_key: String = OS.get_keycode_string(event.keycode)
		
		if pressed_key == key_to_press:
			_success_prompt()


func _success_prompt() -> void:
	_is_active = false
	visible = false
	key_pressed_correct.emit()


func _fail_prompt() -> void:
	_is_active = false
	visible = false
	key_failed.emit()


func _update_timer_display() -> void:
	timer_label.text = "%.1f" % max(_remaining_time, 0.0)
	
	# Change color based on urgency
	if _remaining_time <= 1.0:
		timer_label.modulate = Color(1.0, 0.2, 0.2)  # Red
	elif _remaining_time <= 2.0:
		timer_label.modulate = Color(1.0, 0.8, 0.2)  # Yellow
	else:
		timer_label.modulate = Color(0.2, 1.0, 0.2)  # Green


func _get_readable_key_name(keycode_string: String) -> String:
	# Convert keycode strings to readable names
	var readable_names := {
		"A": "A", "B": "B", "C": "C", "D": "D", "E": "E",
		"F": "F", "G": "G", "H": "H", "I": "I", "J": "J",
		"K": "K", "L": "L", "M": "M", "N": "N", "O": "O",
		"P": "P", "Q": "Q", "R": "R", "S": "S", "T": "T",
		"U": "U", "V": "V", "W": "W", "X": "X", "Y": "Y", "Z": "Z",
		"Space": "SPACE",
		"Shift": "SHIFT",
		"Ctrl": "CTRL",
		"Alt": "ALT"
	}
	
	return readable_names.get(keycode_string, keycode_string)
