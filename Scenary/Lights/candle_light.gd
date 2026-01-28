extends OmniLight3D

@export_range(0, 25, 0.001) var energy_min_value : float #MODIFICABILE DA EDITOR

func _ready() -> void:
	if energy_min_value != light_energy: #SE DIVERSO DAL VALORE DI DEFAULT (VEDI EDITOR) PARTE L'ANIMAZIONE
		setAnim()

var animationDuration : float = 1.5
func setAnim() -> void:
	var tween : Tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "light_energy", light_energy, animationDuration)
	tween.tween_property(self, "light_energy", energy_min_value, animationDuration)
