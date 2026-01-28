extends Area3D
class_name InteractionArea

var canInteract: bool = false
@export var collision : CollisionShape3D

@export var doorNode : DoorLogic = null
@export var maskVisual : MaskVisual = null

func _ready() -> void:
	setCollision()

func setCollision() -> void:
	position = collision.position

func _on_body_entered(_body: Node3D) -> void:
	if maskVisual:
		if (GameManager.is_mask_on):
			if maskVisual.onMaskVisible:
				canInteract = true
		else:
			if !maskVisual.onMaskVisible:
				canInteract = true
	else:
		canInteract = true

func checkInsideArea() -> void:
	if get_overlapping_bodies().size() > 0:
		var body : Node3D = get_overlapping_bodies()[0]
		_on_body_entered(body)

func _on_body_exited(_body: Node3D) -> void:
	#if (GameManager.is_mask_on and maskVisual.onMaskVisible) or (!GameManager.is_mask_on and !maskVisual.onMaskVisible):
	canInteract = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and canInteract:
		if doorNode != null:
			doorNode.interacting()
