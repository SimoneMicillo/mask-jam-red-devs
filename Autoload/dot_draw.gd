extends Control

@export var radius: float = 50
@export var color: Color = Color.WHITE

func _ready():
	queue_redraw()

func _draw():
	draw_circle(size/2, radius, color)
