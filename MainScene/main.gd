extends Node3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Debug: Press P to open Klotski puzzle
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		var puzzle = $KlotskiPuzzle
		if puzzle and not puzzle.visible:
			puzzle.open_puzzle()
