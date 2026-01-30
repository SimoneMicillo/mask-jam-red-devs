extends Node3D

@onready var ui: CanvasLayer = $"../UI"

func _on_player_collider_body_entered(_body: Node3D) -> void:
	$FogVolume2.show()
	get_tree().create_tween().tween_property($FogVolume2, "size", Vector3(9,10.3,14), 1)

func lastRoomTrigger(body: Node3D) -> void:
	pass # Replace with function body.
