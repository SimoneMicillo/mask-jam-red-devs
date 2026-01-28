extends Node

@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var player: Player = $".."
@export var cam_sens : float = 1

var standing_y_pos : float = 0.6
var crouch_y_pos : float = -0.1

# Camera shake variables
var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0
var _original_rotation: Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
	if _shake_timer > 0:
		_shake_timer -= delta
		var shake_amount = _shake_intensity * (_shake_timer / _shake_duration)
		camera_3d.rotation.x = _original_rotation.x + randf_range(-shake_amount, shake_amount) * 0.02
		camera_3d.rotation.z = randf_range(-shake_amount, shake_amount) * 0.01
		
		if _shake_timer <= 0:
			camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-80), deg_to_rad(80))
			camera_3d.rotation.z = 0

## Shake the camera for a demon attack or other effect
## duration: how long to shake in seconds
## intensity: how strong the shake is (10-30 is typical)
func shake(duration: float = 0.5, intensity: float = 15.0) -> void:
	_shake_duration = duration
	_shake_timer = duration
	_shake_intensity = intensity
	_original_rotation = camera_3d.rotation

func _input(event: InputEvent) -> void:
	if !player.isDead: #Aggiungere check if qte_system is active
		if event is InputEventMouseMotion:
			# Trasformiamo la sensibilità in un valore adatto ai radianti
			# Moltiplichiamo per un valore piccolo (es. 0.005) per un controllo fine
			var sensitivity = cam_sens * 0.002
			
			# Ruota il giocatore sull'asse Y (sinistra/destra)
			# Usiamo -= perché solitamente il movimento del mouse è invertito rispetto agli assi
			player.rotate_y(-event.relative.x * sensitivity)
			
			# Ruota la camera su/giù (asse X)
			camera_3d.rotate_x(-event.relative.y * sensitivity)
			# Limita la rotazione verticale per non far ribaltare la camera
			camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
		if Input.is_action_just_pressed("ui_cancel"):
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
