extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setVisibility(true)
	linkToggleMask()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
@export var onMaskVisible: bool
@export var collision: CollisionShape3D
	
func setVisibility(_flag: bool) -> void:
	if GameManager.is_mask_on and onMaskVisible:
		print("po")
		get_parent().show()
		collision.disabled = false
	else:
		get_parent().hide()
		collision.disabled = true

	
func linkToggleMask() -> void:
	GameManager.mask_state_changed.connect(setVisibility)

#Logica nodi visibili o invisibili in base alla maschera: 
#Nodo MaskVisual contiene un flag bool (isVisible o simile)
#Ogni volta che il giocatore attiva o disattiva la maschera check se GameManager.is_mask_active = true AND this.isVisible = true -> SHOW
