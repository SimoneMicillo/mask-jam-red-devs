extends Node3D

@export var fairy_starting_point : Vector3
@onready var fairy: OmniLight3D = $"../fairy"
func _ready() -> void:
	for i : Area3D in get_children():
		i.body_entered.connect(player_entered.bind(i.name))
	fairy.hide()
	fairy.position = fairy_starting_point

func player_entered(_body : Node3D, area_name : String) -> void:
	match area_name:
		"01":
			fairy.show()
			await get_tree().create_timer(.5).timeout
			await get_tree().create_tween().tween_property(fairy, "position", Vector3(33.07, fairy_starting_point.y, -33.117), 1.25).set_trans(Tween.TRANS_BACK).finished
			fairy.hide()
