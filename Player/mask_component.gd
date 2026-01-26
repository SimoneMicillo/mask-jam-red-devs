extends Node

@onready var timer: Timer = $Timer
var isMaskActive : bool = false

@export_category("Sanity Stats")
@export var sanity : float = 100.0
@export var reduceSanityAmount : float = 10.0

func setMaskActive() -> void:
	isMaskActive = true
	timer.start()

func setMaskInactive() -> void:
	isMaskActive = false
	timer.stop()

func _on_timer_timeout() -> void:
	sanity -= reduceSanityAmount
	print("Sanity = ", sanity)
