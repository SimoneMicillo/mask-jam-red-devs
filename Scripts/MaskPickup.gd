extends Node

@export var interaction_area: InteractionArea
@export var mask_visual_node: Node3D
@export var dialogue_controller: CanvasLayer # DialogueUIController

# Texts
const TEXT_1 = "You shouldn't have worn the mask..."
const TEXT_2 = "The mask will possess your mind. Keep your sanity in check, don't let it take over."
const TEXT_3 = "Press SPACE to toggle the mask. Use it wisely to reveal the unseen."
const TEXT_RETURN = "Congratulations! You have reunited the rune fragments to imprison the mask demon."

func _ready() -> void:
	if interaction_area:
		interaction_area.interaction_entered.connect(_on_interaction_entered)
		interaction_area.interaction_exited.connect(_on_interaction_exited)
	
	GameManager.all_fragments_collected.connect(_update_visuals)
	_update_visuals()

func _update_visuals() -> void:
	var was_interactable = false
	if interaction_area: was_interactable = interaction_area.canInteract

	if GameManager.is_mask_on_pedestal:
		if mask_visual_node: mask_visual_node.show()
		if interaction_area: interaction_area.canInteract = true
	else:
		if mask_visual_node: mask_visual_node.hide()
		if GameManager.get_fragments_collected() >= GameManager.TOTAL_FRAGMENTS:
			if interaction_area: interaction_area.canInteract = true 
		else:
			if interaction_area: interaction_area.canInteract = false
	
	# Force re-check if state changed while inside
	if interaction_area and interaction_area.canInteract != was_interactable:
		interaction_area.checkInsideArea()

func _on_interaction_entered() -> void:
	InteractionDot.show_dot()

func _on_interaction_exited() -> void:
	InteractionDot.hide_dot()

@onready var player = get_tree().current_scene.get_node("Player")
func _input(event: InputEvent) -> void:
	if not interaction_area or not interaction_area.canInteract:
		return
		
	if event.is_action_pressed("interact") and $"../PiedistalloFirstRoom".position.distance_to(player.position) < 3:
		if GameManager.is_mask_on_pedestal:
			_start_pickup_sequence()
		elif GameManager.get_fragments_collected() >= GameManager.TOTAL_FRAGMENTS:
			_start_return_sequence()

func _start_pickup_sequence() -> void:
	if not dialogue_controller:
		push_error("MaskPickup: Dialogue Controller not assigned!")
		_complete_pickup() # Fallback
		return
		
	dialogue_controller.show_text(TEXT_1, func():
		dialogue_controller.show_text(TEXT_2, func():
			dialogue_controller.show_text(TEXT_3, _complete_pickup)
		)
	)

func _complete_pickup() -> void:
	GameManager.is_mask_unlocked = true
	GameManager.is_mask_on_pedestal = false
	_update_visuals()
	InteractionDot.hide_dot() # Explicitly hide dot after pickup

func _start_return_sequence() -> void:
	if not dialogue_controller:
		_place_mask_back()
		return
	
	dialogue_controller.show_text(TEXT_RETURN, _place_mask_back)

func _place_mask_back() -> void:
	# End game logic or reset
	GameManager.is_mask_unlocked = false
	GameManager.is_mask_on_pedestal = true
	GameManager.set_mask_state(false)
	_update_visuals()
	InteractionDot.hide_dot()
	# Maybe trigger game completion sequence?
	print("Game Completed!")
