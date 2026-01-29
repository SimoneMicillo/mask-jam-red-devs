extends MeshInstance3D

@export var sprites : Array[Texture2D]

func _ready() -> void:
	GameManager.mask_state_changed.connect(toggle_sprite)
	switch_paintings()

func switch_paintings() -> void:
	$Sprite3D.frame = randi_range(0, 3)

func toggle_sprite(result : bool) -> void:
	if result:
		$Sprite3D.texture = sprites[1]
	else:
		$Sprite3D.texture = sprites[0]
