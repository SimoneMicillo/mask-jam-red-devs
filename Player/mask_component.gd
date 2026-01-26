extends Node
class_name MaskComponent

signal sanityChanged(nSanity : float)

@onready var timer: Timer = $Timer
var isMaskActive : bool = false

@export_category("Sanity Stats")
@export var max_sanity : float = 100.0
var sanity : float
@export var reduceSanityAmount : float = 1.0

func _ready() -> void:
	sanity = max_sanity

func setMaskActive() -> void:
	isMaskActive = true
func setMaskInactive() -> void:
	isMaskActive = false

@onready var player: Player = $".."
func _on_timer_timeout() -> void:
	if isMaskActive:
		if sanity > 0:
			sanity -= reduceSanityAmount
		elif sanity <= 0:
			player.setDead(true) #BUONO 
			
			#OPPURE ALTRO METODO
			#get_parent().setDead(true) #Get_parent prende il padre ("Player") BRUTTO
	#Gestione incremento sanity SE player non ha maschera ON
	#else:
		#if sanity < 100:
			#sanity += reduceSanityAmount
	sanityChanged.emit(sanity)
