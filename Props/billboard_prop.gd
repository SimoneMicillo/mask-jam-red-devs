## BillboardProp
## Base script for billboard sprites (2.5D Doom-style props).
## Automatically keeps the sprite facing the camera/player.
extends Sprite3D
class_name BillboardProp

## If true, only rotates on Y axis (keeps sprite upright)
@export var lock_y_axis: bool = true

## If true, uses custom look_at logic instead of built-in billboard
@export var use_custom_billboard: bool = false

## Reference to the camera (auto-detected if null)
var _camera: Camera3D


func _ready() -> void:
	# If using built-in billboard, ensure it's enabled
	if not use_custom_billboard:
		billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	# Find camera
	_camera = get_viewport().get_camera_3d()


func _process(_delta: float) -> void:
	if use_custom_billboard and _camera != null:
		_look_at_camera()


func _look_at_camera() -> void:
	if _camera == null:
		_camera = get_viewport().get_camera_3d()
		if _camera == null:
			return
	
	var camera_pos: Vector3 = _camera.global_position
	
	if lock_y_axis:
		# Only rotate on Y axis (sprite stays upright)
		var target_pos: Vector3 = Vector3(camera_pos.x, global_position.y, camera_pos.z)
		look_at(target_pos, Vector3.UP)
	else:
		# Full 3D look at
		look_at(camera_pos, Vector3.UP)
	
	# Flip to face camera (sprites face -Z by default)
	rotate_y(PI)
