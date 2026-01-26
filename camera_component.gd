extends Node

@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var player: CharacterBody3D = $".."
@export var cam_sens : float = 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Trasformiamo la sensibilità in un valore adatto ai radianti
		# Moltiplichiamo per un valore piccolo (es. 0.005) per un controllo fine
		var sensitivity = cam_sens * 0.002
		
		# Ruota il giocatore sull'asse Y (sinistra/destra)
		# Usiamo -= perché solitamente il movimento del mouse è invertito rispetto agli assi
		player.rotate_y(-event.relative.x * sensitivity)
		
		## Se vuoi ruotare la camera su/giù (asse X):
		#camera_3d.rotate_x(-event.relative.y * sensitivity)
		# Opzionale: limita la rotazione verticale per non far ribaltare la camera
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
