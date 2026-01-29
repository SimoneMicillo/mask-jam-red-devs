## Fragments HUD
## Displays the current fragment count in the top-right corner
extends CanvasLayer
class_name FragmentsHUD

@onready var fragment_label: Label = $FragmentPanel/HBoxContainer/FragmentLabel
@onready var fragment_panel: Panel = $FragmentPanel

func _ready() -> void:
	GameManager.fragment_collected.connect(_on_fragment_collected)
	_update_display(GameManager.get_fragments_collected(), GameManager.get_total_fragments())

func _on_fragment_collected(current: int, total: int) -> void:
	_update_display(current, total)
	_play_collect_animation()

func _update_display(current: int, total: int) -> void:
	if fragment_label:
		fragment_label.text = "Shreds: %d/%d" % [current, total]

func _play_collect_animation() -> void:
	if fragment_panel:
		var tween = create_tween()
		tween.tween_property(fragment_panel, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(fragment_panel, "scale", Vector2(1.0, 1.0), 0.1)
