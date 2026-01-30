## Fragments HUD
## Displays persistent count (Top-Left) and popup notification (Center)
extends CanvasLayer
class_name FragmentsHUD

# Top-Left HUD References
@onready var fragment_label: Label = $FragmentPanel/HBoxContainer/FragmentLabel

# Center Popup References
@onready var center_notif: Control = $CenterNotification
@onready var large_icon: TextureRect = $CenterNotification/VBoxContainer/LargeIcon
@onready var notif_label: Label = $CenterNotification/VBoxContainer/NotifLabel

# Textures
const TEX_RUNA = preload("res://Assets/hud/runa.png")
const TEX_FRAG_1 = preload("res://Assets/hud/frammento1.png")
const TEX_FRAG_2 = preload("res://Assets/hud/frammento2.png")
const TEX_FRAG_3 = preload("res://Assets/hud/frammento3.png")

func _ready() -> void:
	GameManager.fragment_collected.connect(_on_fragment_collected)
	
	# Initial State HUD
	_update_display(GameManager.get_fragments_collected(), GameManager.get_total_fragments())
	
	# Initial State Popup (Hidden)
	center_notif.visible = false
	center_notif.modulate.a = 0.0

func _on_fragment_collected(current: int, total: int) -> void:
	_update_display(current, total)
	
	# Select texture for popup
	var popup_tex = null
	match current:
		1: popup_tex = TEX_FRAG_1
		2: popup_tex = TEX_FRAG_2
		3: popup_tex = TEX_FRAG_3
		_: popup_tex = TEX_FRAG_3
		
	_show_popup(popup_tex, current, total)

func _update_display(current: int, total: int) -> void:
	fragment_label.text = "Fragment: %d/%d" % [current, total]

func _show_popup(texture: Texture2D, current: int, total: int) -> void:
	if not texture: return
	
	large_icon.texture = texture
	notif_label.text = "Fragment %d/%d Collected!" % [current, total]
	
	center_notif.visible = true
	center_notif.modulate.a = 0.0
	center_notif.scale = Vector2(0.5, 0.5)
	
	var tween = create_tween()
	# Pop in
	tween.parallel().tween_property(center_notif, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(center_notif, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Wait
	tween.tween_interval(2.5)
	
	# Fade out
	tween.tween_property(center_notif, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): center_notif.visible = false)
