extends Node3D

func _on_player_collider_body_entered(_body: Node3D) -> void:
	$FogVolume2.show()
	get_tree().create_tween().tween_property($FogVolume2, "size", Vector3(9,10.3,14), 1)
