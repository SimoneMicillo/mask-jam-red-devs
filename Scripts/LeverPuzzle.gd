extends Node

@export var levers_masked: Array[LeverLogic]
@export var lever_normal: LeverLogic

var activated_count: int = 0
const TOTAL_LEVERS: int = 4

func _ready() -> void:
	# Connect signals from masked levers
	for lever in levers_masked:
		if lever:
			lever.activated.connect(_on_masked_lever_activated)
			lever.set_visible_only_masked(true)
	
	# Connect signal from normal lever
	if lever_normal:
		lever_normal.activated.connect(_on_normal_lever_activated)
		lever_normal.set_visible_only_masked(false) 
		lever_normal.set_visible_only_normal(true) # Visible only without mask
		lever_normal.set_force_hidden(true) # Initially locked/hidden

func _on_masked_lever_activated() -> void:
	activated_count += 1
	check_puzzle_state()

func _on_normal_lever_activated() -> void:
	activated_count += 1
	check_puzzle_state()

func check_puzzle_state() -> void:
	# Requirement: "leva normal visibile solo quando abbiamo premuto almeno due leve con la maschera"
	# We interpret this as: 2 masked levers actiavted -> show normal lever.
	Sounds.get_node("leverSound").play()
	
	var masked_activated = 0
	for lever in levers_masked:
		if lever.is_activated:
			masked_activated += 1
			
	if masked_activated >= 2 and lever_normal:
		# Unlock the lever. Its visibility is now controlled by mask state (OFF = Visible)
		lever_normal.set_force_hidden(false)
		
	# Check completion
	if activated_count >= TOTAL_LEVERS:
		_complete_puzzle()

func _complete_puzzle() -> void:
	print("Puzzle Completed! Granting Fragment.")
	GameManager.collect_fragment("lever_puzzle")
