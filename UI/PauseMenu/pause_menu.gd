## PauseMenu
## Pause menu overlay for THE MASK game.
## Handles Resume, Settings, and Return to Main Menu.
extends CanvasLayer

@onready var settings_panel: Control = $PausePanel/SettingsPanel
@onready var main_buttons: Control = $PausePanel/MainButtons
@onready var sensitivity_slider: HSlider = $PausePanel/SettingsPanel/VBoxContainer/SensitivitySlider
@onready var sensitivity_label: Label = $PausePanel/SettingsPanel/VBoxContainer/SensitivityLabel

#AUDIO
@export var sound_sliders : Array[Slider]
@export var sound_labels : Array[Label]

var is_paused: bool = false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	initSoundSliders()
	_load_settings()

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

#AUDIO LOGIC
func initSoundSliders() -> void:
	for i : Slider in sound_sliders:
		i.value_changed.connect(_on_volume_slider_value_changed.bind(i))
func _on_volume_slider_value_changed(value: float, slider : Slider) -> void:
	if slider.name.contains("master"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	elif slider.name.contains("music"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	
	_update_slider_labels()

func _on_sensitivity_slider_value_changed(_value: float) -> void:
	_update_slider_labels()

func _update_slider_labels() -> void:
	sound_labels[0].text = "Master: " + str(int(sound_sliders[0].value * 100)) + "%"
	sound_labels[1].text = "Music: " + str(int(sound_sliders[1].value * 100)) + "%"
	sound_labels[2].text = "SFX: " + str(int(sound_sliders[2].value * 100)) + "%"
	
	if sensitivity_label and sensitivity_slider:
		sensitivity_label.text = "Sensibilità: " + str(snapped(sensitivity_slider.value, 0.1))

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("master_vol", "master_volume", sound_sliders[0].value)
	config.set_value("music_vol", "music_volume", sound_sliders[1].value)
	config.set_value("sound_vol", "sound_volume", sound_sliders[2].value)
	
	config.set_value("controls", "mouse_sensitivity", sensitivity_slider.value)
	config.save("user://settings.cfg")

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		sound_sliders[0].value = config.get_value("master_vol", "master_volume", 1.0)
		sound_sliders[1].value = config.get_value("music_vol", "music_volume", 1.0)
		sound_sliders[2].value = config.get_value("sound_vol", "sound_volume", 1.0)
		
		if sensitivity_slider:
			sensitivity_slider.value = config.get_value("controls", "mouse_sensitivity", 1.0)
		_update_slider_labels()

#VIDEO
func setFs(toggled : bool) -> void:
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
func setRes(idx : int) -> void:
	match idx:
		0:
			DisplayServer.window_set_size(Vector2(1024,768))
		1:
			DisplayServer.window_set_size(Vector2(1280,720))
		2:
			DisplayServer.window_set_size(Vector2(1440,900))
		3:
			DisplayServer.window_set_size(Vector2(1920,1080))
