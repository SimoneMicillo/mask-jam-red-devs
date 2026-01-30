extends Node3D

@onready var hud: CanvasLayer = $"../UI"

func _on_player_collider_body_entered(_body: Node3D) -> void:
	$FogVolume2.show()
	get_tree().create_tween().tween_property($FogVolume2, "size", Vector3(9,10.3,14), 1)

func lastRoomTrigger(_body: Node3D) -> void:
	hud.get_node("lastRoomLabl").show()
	await get_tree().create_timer(3).timeout
	hud.get_node("lastRoomLabl").hide()
