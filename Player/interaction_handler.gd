extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var interactingBody: Node3D

func _on_body_entered(body: Node3D) -> void:
	if body.has_node("Door"):
		body.get_node("Door").canInteract = true
		interactingBody = body
