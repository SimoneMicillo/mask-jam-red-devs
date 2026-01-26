extends Node
class_name MaskComponent

signal sanityChanged(nSanity : float)

@onready var timer: Timer = $Timer
var isMaskActive : bool = false

@export_category("Sanity Stats")

@export var max_sanity : float = 100.0
var sanity : float
@export var reduceSanityAmount : float = 10.0

func _ready() -> void:
	sanity = max_sanity

func setMaskActive() -> void:
	isMaskActive = true
	timer.start()

func setMaskInactive() -> void:
	isMaskActive = false
	timer.stop()

func _on_timer_timeout() -> void:
	sanity -= reduceSanityAmount
	sanityChanged.emit(sanity)
