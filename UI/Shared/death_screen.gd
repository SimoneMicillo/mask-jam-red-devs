## DeathScreen
## Game Over / Death screen for THE MASK.
## Shows when player sanity reaches 0.
extends CanvasLayer

@onready var death_panel: Control = $DeathPanel


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect to GameManager game_over signal
	GameManager.game_over.connect(_on_game_over)


func _on_game_over() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	
	# Animate the panel appearance
	death_panel.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(death_panel, "modulate:a", 1.0, 0.5)


func _on_retry_pressed() -> void:
	visible = false
	get_tree().paused = false
	SceneLoader.reload_current_scene()


func _on_main_menu_pressed() -> void:
	visible = false
	get_tree().paused = false
	SceneLoader.change_scene("res://UI/MainMenu/main_menu.tscn")
