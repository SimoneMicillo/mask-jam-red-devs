extends Node3D

@onready var hud: CanvasLayer = $"../UI"

func _on_player_collider_body_entered(_body: Node3D) -> void:
	$FogVolume2.show()
	get_tree().create_tween().tween_property($FogVolume2, "size", Vector3(9,10.3,14), 1)

func lastRoomTrigger(_body: Node3D) -> void:
	hud.get_node("lastRoomLabl").show()
	await get_tree().create_timer(3).timeout
	hud.get_node("lastRoomLabl").hide()

func _process(delta: float) -> void:
	updateInfiniteCorridorUV(delta)

func updateInfiniteCorridorUV(delta: float) -> void:
	$Node3D/CorridorLoop.get_active_material(0).uv1_offset += Vector3(.25*delta,.25*delta,0)
	$DoorLoopRoom_Wall/MeshInstance3D2.get_active_material(0).uv1_offset -= Vector3(.25*delta,.25*delta,0)
