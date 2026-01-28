extends Node
class_name DoorLogic

@export var pivot: StaticBody3D
var isOpen: bool = false

@export var interactionArea : InteractionArea

func _ready() -> void:
	findInteractionArea()

func findInteractionArea() -> void:
	if get_parent().has_node("InteractionArea"):
		interactionArea = get_parent().get_node("InteractionArea")

@export_category("Animation Params")
@export var open_deg_target_y : float
@export var close_deg_target_y : float
@export var anim_duration : float = .75
func interacting() -> void:
	if !isOpen and interactionArea.canInteract:
		# apri
		get_tree().create_tween().tween_property(pivot, "rotation_degrees:y", open_deg_target_y, anim_duration).set_trans(Tween.TRANS_BACK)
		isOpen = true
	elif isOpen and interactionArea.canInteract:
		# chiudi
		get_tree().create_tween().tween_property(pivot, "rotation_degrees:y", close_deg_target_y, anim_duration).set_trans(Tween.TRANS_BACK)
		isOpen = false
