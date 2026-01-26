## PauseMenu
## Pause menu overlay for THE MASK game.
## Handles Resume, Settings, and Return to Main Menu.
extends CanvasLayer

@onready var settings_panel: Control = $PausePanel/SettingsPanel
@onready var main_buttons: Control = $PausePanel/MainButtons
@onready var volume_slider: HSlider = $PausePanel/SettingsPanel/VBoxContainer/VolumeSlider
@onready var sensitivity_slider: HSlider = $PausePanel/SettingsPanel/VBoxContainer/SensitivitySlider
@onready var volume_label: Label = $PausePanel/SettingsPanel/VBoxContainer/VolumeLabel
@onready var sensitivity_label: Label = $PausePanel/SettingsPanel/VBoxContainer/SensitivityLabel

var is_paused: bool = false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_settings()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not GameManager.is_game_over():
		toggle_pause()


func toggle_pause() -> void:
	is_paused = !is_paused
	visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		settings_panel.visible = false
		main_buttons.visible = true
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_resume_pressed() -> void:
	toggle_pause()


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	settings_panel.visible = true


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	SceneLoader.change_scene("res://UI/MainMenu/main_menu.tscn")


func _on_back_pressed() -> void:
	settings_panel.visible = false
	main_buttons.visible = true
	_save_settings()


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	_update_slider_labels()


func _on_sensitivity_slider_value_changed(value: float) -> void:
	_update_slider_labels()


func _update_slider_labels() -> void:
	if volume_label and volume_slider:
		volume_label.text = "Volume: " + str(int(volume_slider.value * 100)) + "%"
	if sensitivity_label and sensitivity_slider:
		sensitivity_label.text = "Sensibilità: " + str(snapped(sensitivity_slider.value, 0.1))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", volume_slider.value)
	config.set_value("controls", "mouse_sensitivity", sensitivity_slider.value)
	config.save("user://settings.cfg")


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		if volume_slider:
			volume_slider.value = config.get_value("audio", "master_volume", 1.0)
		if sensitivity_slider:
			sensitivity_slider.value = config.get_value("controls", "mouse_sensitivity", 1.0)
		_update_slider_labels()
