extends Node

@export var pivot: StaticBody3D
var canInteract: bool = false
var isOpen: bool = false

func setCanInteract(value: bool) -> void:
	canInteract = value
	pass
	
func interacting() -> void:
	if !isOpen and canInteract:
		# apri
		get_tree().create_tween().tween_property(pivot, "rotation:y", 90, .25)
		isOpen = true
	elif isOpen and canInteract:
		# chiudi
		get_tree().create_tween().tween_property(pivot, "rotation:y", -90, .25)
		isOpen = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
