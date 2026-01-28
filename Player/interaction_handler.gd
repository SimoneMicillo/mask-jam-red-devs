extends Area3D
class_name InteractionArea

var canInteract: bool = false
@export var collision : CollisionShape3D

@export var doorNode : DoorLogic
@export var maskVisual : MaskVisual

func _ready() -> void:
	setCollision()

func setCollision() -> void:
	position = collision.position

func _on_body_entered(_body: Node3D) -> void:
	if (GameManager.is_mask_on):
		if maskVisual.onMaskVisible:
			canInteract = true
	else:
		if !maskVisual.onMaskVisible:
			canInteract = true


func _on_body_exited(_body: Node3D) -> void:
	#if (GameManager.is_mask_on and maskVisual.onMaskVisible) or (!GameManager.is_mask_on and !maskVisual.onMaskVisible):
	canInteract = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and canInteract:
		if doorNode != null:
			doorNode.interacting()
