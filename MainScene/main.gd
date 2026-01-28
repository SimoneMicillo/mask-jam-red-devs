extends Node3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Debug: Press P to open Klotski puzzle
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		var puzzle = $KlotskiPuzzle
		if puzzle and not puzzle.visible:
			puzzle.open_puzzle()
	
	# Debug: Press O to open Klotski puzzle 2 (easier version)
	if event is InputEventKey and event.pressed and event.keycode == KEY_O:
		var puzzle2 = $KlotskiPuzzle2
		if puzzle2 and not puzzle2.visible:
			puzzle2.open_puzzle()

