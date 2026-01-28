extends Area3D

@export var target_pos : Vector3 #Target position per il teleport
@export var teleport_masked : bool #Flag per determinare se il teleport avviene per il giocatore se mascherato o no

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("PlayerGroup"):
		body.position = target_pos
