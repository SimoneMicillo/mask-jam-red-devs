extends CanvasLayer

@onready var player: CharacterBody3D = $"../Player"
@onready var playerMask : MaskComponent = $"../Player".get_node("MaskComponent")

func _ready() -> void:
	player.get_node("MaskComponent").sanityChanged.connect(updateSanityUI)

func updateSanityUI(nVal : float) -> void:
	if nVal >= playerMask.sanity:
		
	$sanity.text = "Sanity = " + str(nVal)
