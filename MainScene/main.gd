extends Node3D

@export var starting_point : Vector3 = Vector3(-30.691,2.5,9.5)
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Player.position = starting_point

func _input(event: InputEvent) -> void:
	# Block puzzle inputs if QTE is active
	var qte_active = false
	if has_node("QteSystem"):
		var qte_node = $QteSystem
		if qte_node.visible:
			qte_active = true
		
	if qte_active:
		# If QTE is active, DO NOT allow opening puzzles
		if event is InputEventKey and event.pressed and event.keycode == KEY_P:
			# print("DEBUG: Puzzle input BLOCKED because QTE is active") # Optional debug
			pass
		return
	
	# Debug: Press P to open Klotski puzzle 1
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		var puzzle = $KlotskiPuzzle
		if puzzle and not puzzle.visible:
			puzzle.open_puzzle()
