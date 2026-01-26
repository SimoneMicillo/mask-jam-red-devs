extends CharacterBody3D
class_name Player

const SPEED: float = 7.5
var isDead: bool = false
var isCrouched: bool = false

@onready var camera_3d: Camera3D = $Camera3D
@onready var camera_component: Node = $CameraComponent
@onready var collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	# Connect to global GameManager for game over
	GameManager.game_over.connect(_on_game_over)


func _physics_process(delta: float) -> void:
	if isDead:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _input(_event: InputEvent) -> void:
	if isDead:
		return
	
	# Mask toggle - uses global GameManager
	if Input.is_action_just_pressed("toggle_mask"):
		GameManager.toggle_mask()
	
	# Crouch toggle
	if Input.is_action_just_pressed("crouch"):
		if isCrouched:
			get_tree().create_tween().tween_property(camera_3d, "position:y", camera_component.standing_y_pos, 0.1)
			isCrouched = false
			collision.shape = preload("res://Assets/collisions/standingShape.tres")
			collision.shape.height = 2.0
			collision.position = Vector3.ZERO
		else:
			get_tree().create_tween().tween_property(camera_3d, "position:y", camera_component.crouch_y_pos, 0.1)
			collision.shape = preload("res://Assets/collisions/crouchShape.tres")
			collision.position = Vector3(0, -0.45, 0)
			isCrouched = true


func _on_game_over() -> void:
	isDead = true
	dead.emit()


# Legacy signal for backwards compatibility with UI
signal dead
