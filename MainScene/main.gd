extends Node3D

@export var starting_point : Vector3 = Vector3(-30.691,2.5,9.5)
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Player.position = starting_point
	GameManager.request_open_puzzle.connect(_on_request_open_puzzle)

func _on_request_open_puzzle(puzzle_name: String) -> void:
	if puzzle_name == "Klotski":
		open_klotski_puzzle()

func open_klotski_puzzle() -> void:
	var puzzle = $KlotskiPuzzle
	if puzzle and not puzzle.visible:
		puzzle.open_puzzle()

func _input(event: InputEvent) -> void:
	# Block puzzle inputs if QTE is active
	var qte_active = false
	if has_node("QteSystem"):
		var qte_node = $QteSystem
		if qte_node.visible:
			qte_active = true
		
	if qte_active:
		return
