extends CharacterBody3D
class_name Player

const SPEED = 7.5
var isDead : bool = false

func _physics_process(delta: float) -> void:
	if !isDead:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
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
	if !isDead:
		if Input.is_action_just_pressed("ui_accept"):
			if $MaskComponent.isMaskActive:
				$MaskComponent.setMaskInactive()
			else:
				$MaskComponent.setMaskActive()

signal dead
func setDead(val : bool) -> void:
	isDead = val
	dead.emit()
