extends CanvasLayer

@onready var dot = $Dot

func show_dot():
	dot.visible = true

func hide_dot():
	dot.visible = false
