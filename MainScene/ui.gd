extends CanvasLayer

@onready var player: Player = $"../Player"
@onready var playerMask : MaskComponent = $"../Player".get_node("MaskComponent")

func _ready() -> void:
	playerMask.sanityChanged.connect(updateSanityUI)
	player.dead.connect(setGameOver)

func updateSanityUI(nVal : float) -> void:
	$sanity.text = "Sanity = " + str(nVal)
	if nVal >= playerMask.max_sanity:
		get_tree().create_tween().tween_property($sanity, "modulate", Color(1.0, 1.0, 1.0, 0.0), .25)
	elif nVal < playerMask.max_sanity:
		if nVal <= playerMask.max_sanity / 3:
			get_tree().create_tween().tween_property($sanity, "modulate", Color(1.0, 0.0, 0.0, 1.0), .25)
		elif nVal <= playerMask.max_sanity / 2:
			get_tree().create_tween().tween_property($sanity, "modulate", Color(1.0, 1.0, 0.0, 1.0), .25)
		else:
			get_tree().create_tween().tween_property($sanity, "modulate", Color(1.0, 1.0, 1.0, 1.0), .25)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
func _on_quit_pressed() -> void:
	get_tree().quit()

func setGameOver() -> void:
	$GameOver.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
