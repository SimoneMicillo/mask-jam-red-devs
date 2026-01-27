## MainMenu
## Main menu screen for THE MASK game.
## Handles Play, Settings, and Quit functionality.
extends Control

@onready var settings_panel: Control = $SettingsPanel
#@onready var volume_slider: HSlider = $SettingsPanel/VBoxContainer/VolumeSlider
@onready var sensitivity_slider: HSlider = $SettingsPanel/VBoxContainer/SensitivitySlider
#@onready var volume_label: Label = $SettingsPanel/VBoxContainer/VolumeLabel
@onready var sensitivity_label: Label = $SettingsPanel/VBoxContainer/SensitivityLabel

#AUDIO
@export var sound_sliders : Array[Slider]
@export var sound_labels : Array[Label]

# Settings stored in GameManager or local
var master_volume: float = 1.0
var music_volume : float = 1.0
var sound_volume : float = 1.0
var mouse_sensitivity: float = 1.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	settings_panel.visible = false
	
	initSoundSliders()
	
	# Load saved settings if available
	_load_settings()
	_update_slider_labels()

func _on_play_pressed() -> void:
	SceneLoader.change_scene("res://MainScene/main.tscn")

func _on_settings_pressed() -> void:
	settings_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	settings_panel.visible = false
	_save_settings()

#AUDIO LOGIC
func initSoundSliders() -> void:
	for i : Slider in sound_sliders:
		i.value_changed.connect(_on_volume_slider_value_changed.bind(i))
func _on_volume_slider_value_changed(value: float, slider : Slider) -> void:
	if slider.name.contains("master"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
		master_volume = value
	elif slider.name.contains("music"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
		music_volume = value
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
		sound_volume = value
	
	_update_slider_labels()

func _on_sensitivity_slider_value_changed(value: float) -> void:
	mouse_sensitivity = value
	
	# Store in a global if needed
	if GameManager.has_method("set_sensitivity"):
		GameManager.set_sensitivity(value)
	_update_slider_labels()

func _update_slider_labels() -> void:
	sound_labels[0].text = "Master: " + str(int(master_volume * 100)) + "%"
	sound_labels[1].text = "Music: " + str(int(music_volume * 100)) + "%"
	sound_labels[2].text = "SFX: " + str(int(sound_volume * 100)) + "%"
	
	if sensitivity_label:
		sensitivity_label.text = "Sensibilità: " + str(snapped(mouse_sensitivity, 0.1))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.save("user://settings.cfg")

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
		mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", 1.0)
		
		#if volume_slider:
			#volume_slider.value = master_volume
		if sensitivity_slider:
			sensitivity_slider.value = mouse_sensitivity
		
		AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
