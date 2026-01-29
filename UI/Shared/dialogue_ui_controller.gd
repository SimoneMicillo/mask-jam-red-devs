extends CanvasLayer

signal dialogue_finished

@onready var panel: Panel = $Control/Panel
@onready var text_label: RichTextLabel = $Control/Panel/RichTextLabel
@onready var continue_button: Button = $Control/Panel/Button

var _on_complete_callback: Callable

func _ready() -> void:
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)

func show_text(text: String, on_complete: Callable = Callable()) -> void:
	text_label.text = text
	_on_complete_callback = on_complete
	visible = true
	
	# Pause the game and show mouse cursor
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_continue_pressed() -> void:
	visible = false
	
	# Resume game and capture mouse cursor
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	emit_signal("dialogue_finished")
	if _on_complete_callback.is_valid():
		_on_complete_callback.call()
