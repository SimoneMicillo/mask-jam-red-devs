extends Node3D

@export var door_logic: DoorLogic

const KLOTSKI_ID = "Klotski" # Must match ID in KlotskiActivator or generic puzzle handling if applicable

func _ready() -> void:
	print("DEBUG: FireplaceAutomation _ready. DoorLogic: ", door_logic)
	# Listen for real-time solution
	GameManager.klotski_solved.connect(_on_klotski_solved)
	
	# Check if already solved (persisted state check if implemented, currently relying on signals/global state)
	if GameManager.is_puzzle_completed(KLOTSKI_ID):
		print("DEBUG: Klotski already solved on startup.")
		_on_klotski_solved()

func _on_klotski_solved() -> void:
	print("DEBUG: FireplaceAutomation received klotski_solved signal!")
	if door_logic:
		print("DEBUG: Opening fireplace door...")
		# Small delay to let the puzzle UI closing animation finish or just for dramatic effect
		await get_tree().create_timer(1.0).timeout 
		door_logic.force_open()
		Sounds.get_node("camino").play()
	else:
		print("ERROR: DoorLogic is null in FireplaceAutomation!")
