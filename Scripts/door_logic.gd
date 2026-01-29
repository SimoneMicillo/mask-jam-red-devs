extends Node
class_name DoorLogic

@export var pivot: Node3D
var isOpen: bool = false

@export var interactionArea : InteractionArea

func _ready() -> void:
	findInteractionArea()
	
	if interactionArea:
		interactionArea.interaction_entered.connect(_on_interaction_entered)
		interactionArea.interaction_exited.connect(_on_interaction_exited)

func _on_interaction_entered():
	InteractionDot.show_dot()
func _on_interaction_exited():
	InteractionDot.hide_dot()

func findInteractionArea() -> void:
	if get_parent().has_node("InteractionArea"):
		interactionArea = get_parent().get_node("InteractionArea")

@export_category("Animation Params")
@export var open_pos_target : Vector3

@export var open_deg_target_y : float
@export var close_deg_target_y : float
@export var anim_duration : float = .75
func interacting() -> void:
	if !isOpen and interactionArea.canInteract:
		# apri
		get_tree().create_tween().tween_property(pivot, "rotation_degrees:y", open_deg_target_y, anim_duration).set_trans(Tween.TRANS_BACK)
		get_tree().create_tween().tween_property(pivot, "position", open_pos_target, anim_duration).set_trans(Tween.TRANS_BACK)
		isOpen = true
	elif isOpen and interactionArea.canInteract:
		# chiudi
		get_tree().create_tween().tween_property(pivot, "rotation_degrees:y", close_deg_target_y, anim_duration).set_trans(Tween.TRANS_BACK)
		isOpen = false
