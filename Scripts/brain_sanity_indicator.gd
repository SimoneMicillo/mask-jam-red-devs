extends TextureRect
class_name BrainSanityIndicator

@export_group("Sprite Sheet Configuration")
@export var brain_texture: Texture2D 
@export var frames_in_sheet: int = 5
@export var frames_horizontal: int = 5
@export var frames_vertical: int = 1

# Configurazione Visiva
@export_group("Visual Settings")
@export var position_offset: Vector2 = Vector2(20, -220) 
@export var brain_scale: float = 1.0
@export var smooth_transition: bool = true
@export var transition_duration: float = 0.3

@export_group("Sanity Mapping")

@export var sanity_thresholds: Array[float] = [75.0, 50.0, 25.0, 10.0, 0.0]

var current_frame: int = 0
var frame_size: Vector2 = Vector2.ZERO
var atlas_texture: AtlasTexture


func _ready() -> void:
	_setup_position()
	
	_setup_atlas_texture()
	
	if GameManager:
		GameManager.sanity_changed.connect(_on_sanity_changed)
		_on_sanity_changed(GameManager.current_sanity)
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _setup_position() -> void:
	anchor_left = 0.0
	anchor_top = 1.0
	anchor_right = 0.0
	anchor_bottom = 1.0
	
	grow_horizontal = Control.GROW_DIRECTION_END
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	if brain_texture:
		var single_frame_width: float = brain_texture.get_width() / float(frames_horizontal)
		var single_frame_height: float = brain_texture.get_height() / float(frames_vertical)
		frame_size = Vector2(single_frame_width, single_frame_height) * brain_scale
	else:
		frame_size = Vector2(128, 128) * brain_scale
	
	offset_left = position_offset.x
	offset_top = position_offset.y
	offset_right = position_offset.x + frame_size.x
	offset_bottom = position_offset.y + frame_size.y
	
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL


func _setup_atlas_texture() -> void:
	if not brain_texture:
		push_warning("BrainSanityIndicator: Nessuna texture assegnata!")
		return
	
	var single_frame_width: float = brain_texture.get_width() / float(frames_horizontal)
	var single_frame_height: float = brain_texture.get_height() / float(frames_vertical)
	frame_size = Vector2(single_frame_width, single_frame_height)
	
	atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = brain_texture
	
	atlas_texture.region = Rect2(0, 0, frame_size.x, frame_size.y)
	
	texture = atlas_texture
	
	custom_minimum_size = frame_size * brain_scale


func _on_sanity_changed(new_sanity: float) -> void:
	var target_frame: int = _get_frame_for_sanity(new_sanity)
	
	if target_frame != current_frame:
		_change_frame(target_frame)


func _get_frame_for_sanity(sanity: float) -> int:
	var max_sanity: float = GameManager.max_sanity if GameManager else 100.0
	var sanity_percent: float = (sanity / max_sanity) * 100.0
	
	if sanity_thresholds.size() > 0:
		for i in range(sanity_thresholds.size()):
			if sanity_percent >= sanity_thresholds[i]:
				return mini(i, frames_in_sheet - 1)
		return frames_in_sheet - 1
	else:
		var frame_percent: float = 100.0 / float(frames_in_sheet)
		
		for i in range(frames_in_sheet):
			var threshold_min: float = 100.0 - ((i + 1) * frame_percent)
			
			if sanity_percent > threshold_min:
				return i
		
		return frames_in_sheet - 1


func _change_frame(new_frame: int) -> void:
	if not atlas_texture:
		return
	
	new_frame = clampi(new_frame, 0, frames_in_sheet - 1)
	
	if smooth_transition:
		_change_frame_smooth(new_frame)
	else:
		_change_frame_instant(new_frame)
	
	current_frame = new_frame


func _change_frame_instant(frame_index: int) -> void:
	# Calcola posizione del frame nella sprite sheet
	var frame_x: int = frame_index % frames_horizontal
	var frame_y: int = frame_index / frames_horizontal
	
	var region_x: float = frame_x * frame_size.x
	var region_y: float = frame_y * frame_size.y
	
	atlas_texture.region = Rect2(region_x, region_y, frame_size.x, frame_size.y)


func _change_frame_smooth(frame_index: int) -> void:
	# Fade out
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, transition_duration / 2.0)
	await tween.finished
	
	_change_frame_instant(frame_index)
	
	# Fade in
	var tween2: Tween = create_tween()
	tween2.tween_property(self, "modulate:a", 1.0, transition_duration / 2.0)


func preview_frame(frame_index: int) -> void:
	_change_frame_instant(frame_index)


func pulse_effect() -> void:
	var original_scale: Vector2 = scale
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", original_scale * 1.15, 0.1)
	tween.tween_property(self, "scale", original_scale, 0.15)


var _shake_tween: Tween = null

func start_shake_effect(intensity: float = 3.0) -> void:
	if _shake_tween and _shake_tween.is_valid():
		return
	
	var original_offset_left: float = offset_left
	var original_offset_top: float = offset_top
	
	_shake_tween = create_tween()
	_shake_tween.set_loops()
	
	for i in range(4):
		var random_x: float = randf_range(-intensity, intensity)
		var random_y: float = randf_range(-intensity, intensity)
		_shake_tween.tween_property(self, "offset_left", original_offset_left + random_x, 0.05)
		_shake_tween.tween_property(self, "offset_top", original_offset_top + random_y, 0.05)


func stop_shake_effect() -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
		_shake_tween = null
	
	offset_left = position_offset.x
	offset_top = position_offset.y
