extends Node
class_name MaskVisual

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setVisibility(true)
	linkToggleMask()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

@export var onMaskVisible: bool
@export var isDoor: bool
@export var collision: CollisionShape3D

func setVisibility(_flag: bool) -> void:
	if !isDoor:
		if GameManager.is_mask_on and onMaskVisible:
			get_parent().show()
			collision.disabled = false
		else:
			get_parent().hide()
			collision.disabled = true
	else:
		if GameManager.is_mask_on:
			# Implementare logica delle porte; caricare texture porta
			get_parent().show()
			pass
		elif !GameManager.is_mask_on:
			#caricare texture muro
			get_parent().hide()
			pass

func linkToggleMask() -> void:
	GameManager.mask_state_changed.connect(setVisibility)
