extends CharacterBody3D
class_name Player

@export var SPEED: float = 12.5
@export var MASKED_SPEED: float = 19
@onready var CROUCHED_SPEED: float = SPEED/2
@onready var MASKED_CROUCHED_SPEED: float = MASKED_SPEED/2

var isDead: bool = false
var isCrouched: bool = false

@onready var camera_3d: Camera3D = $Camera3D
@onready var camera_component: Node = $CameraComponent
@onready var collision: CollisionShape3D = $CollisionShape3D

@onready var pause_menu: CanvasLayer = $"../PauseMenu"

func _ready() -> void:
	# Connect to global GameManager for game over
	GameManager.game_over.connect(_on_game_over)

func _physics_process(delta: float) -> void:
	if isDead:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var actualSpeed := 0.0
	if !isCrouched and !GameManager.is_mask_on:
		actualSpeed = SPEED
	elif isCrouched and !GameManager.is_mask_on:
		actualSpeed = CROUCHED_SPEED
	elif !isCrouched and GameManager.is_mask_on:
		actualSpeed = MASKED_SPEED
	else:
		actualSpeed = MASKED_CROUCHED_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * actualSpeed
		velocity.z = direction.z * actualSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, actualSpeed)
		velocity.z = move_toward(velocity.z, 0, actualSpeed)

	move_and_slide()

# Function used only for debug purpose
func get_crouch_height() -> float:
	var shape := collision.shape
	if shape is CapsuleShape3D:
		print(shape.height + shape.radius * 2.0)
		return shape.height + shape.radius * 2.0
	
	return 0.0

@onready var standing_shape: Shape3D = preload("res://Assets/collisions/standingShape.tres")
@onready var crouch_shape: Shape3D = preload("res://Assets/collisions/crouchShape.tres")

@onready var crouch_height: float = crouch_shape.height + crouch_shape.radius * 2.0
@onready var standing_height: float = standing_shape.height + standing_shape.radius * 2.0
@onready var stand_up_offset: float = standing_height - crouch_height

func can_stand_up() -> bool:
	var space := get_world_3d().direct_space_state

	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = standing_shape
	params.transform = global_transform.translated(Vector3.UP * stand_up_offset)
	params.exclude = [self]
	
	params.collision_mask = collision.get_parent().collision_mask

	var result := space.intersect_shape(params, 1)
	return result.is_empty()

func _input(event: InputEvent) -> void:
	if isDead:
		return
	
	# Mask toggle - uses global GameManager
	if event.is_action_pressed("toggle_mask"):
		GameManager.toggle_mask()
	
	# Crouch toggle
	if event.is_action_pressed("crouch"):
		if isCrouched:
			if not can_stand_up():
				return
			
			get_tree().create_tween().tween_property(
				camera_3d,
				"position:y",
				camera_component.standing_y_pos,
				0.1
			)
			
			collision.shape = standing_shape
			collision.position = Vector3.ZERO
			isCrouched = false
		else:
			get_tree().create_tween().tween_property(
				camera_3d,
				"position:y",
				camera_component.crouch_y_pos,
				0.1
			)
			
			collision.shape = crouch_shape
			collision.position = Vector3(0, -0.45, 0)
			isCrouched = true
			
	if event.is_action_pressed("debug_qte"):
		if $"../QteSystem".visible:
			$"../QteSystem"._hide()
		else:
			$"../QteSystem"._show()
	
	if event.is_action_pressed("ui_cancel") and not GameManager.is_game_over():
		pause_menu.toggle_pause()
	
	if event.is_action_pressed("interact"):
		if $InteractionArea.interactingBody:
			$InteractionArea.interactingBody.get_node("Door").interacting()

func _on_game_over() -> void:
	isDead = true
	dead.emit()

# Legacy signal for backwards compatibility with UI
signal dead
