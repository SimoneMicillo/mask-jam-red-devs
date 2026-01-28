## Demon Warning System
## Shows a demon that grows on screen when mask is worn too long,
## then triggers a QTE attack sequence.
extends CanvasLayer
class_name DemonWarning

signal demon_attack_started()
signal demon_attack_ended(damage_taken: float)

# Configuration
@export var mask_time_before_warning: float = 5.0  # Seconds before demon appears
@export var growth_interval: float = 2.0  # Seconds between size increases
@export var max_growth_stages: int = 4  # Number of growth stages before attack
@export var initial_scale: float = 0.3  # Starting scale of demon
@export var scale_increment: float = 0.2  # How much to grow each stage
@export var damage_per_attack: float = 5.0  # 5% vita per attacco

# State
var _mask_worn_time: float = 0.0
var _is_warning_active: bool = false
var _current_growth_stage: int = 0
var _growth_timer: float = 0.0
var _is_attacking: bool = false

# UI References
@onready var demon_sprite: TextureRect = $DemonContainer/DemonSprite
@onready var demon_container: Control = $DemonContainer
@onready var qte_system: QTESystem = null

func _ready() -> void:
	# Hide initially
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect to GameManager
	GameManager.mask_state_changed.connect(_on_mask_state_changed)
	
	# Find QTE system
	await get_tree().process_frame
	_find_qte_system()

func _find_qte_system() -> void:
	qte_system = get_tree().get_first_node_in_group("qte_system") as QTESystem
	if qte_system == null:
		var qte_nodes = get_tree().root.find_children("*", "QTESystem", true, false)
		if qte_nodes.size() > 0:
			qte_system = qte_nodes[0]
	
	if qte_system != null:
		qte_system.qte_completed.connect(_on_qte_completed)

func _process(delta: float) -> void:
	if _is_attacking:
		return
	
	if GameManager.is_mask_on:
		_mask_worn_time += delta
		
		# Check if we should start showing warning
		if _mask_worn_time >= mask_time_before_warning and not _is_warning_active:
			_start_warning()
		
		# Handle growth stages
		if _is_warning_active:
			_growth_timer += delta
			if _growth_timer >= growth_interval:
				_growth_timer = 0.0
				_grow_demon()

func _on_mask_state_changed(is_active: bool) -> void:
	if is_active:
		# Mask just put on - reset timer
		_mask_worn_time = 0.0
	else:
		# Mask removed - hide warning and reset
		if _is_warning_active and not _is_attacking:
			_stop_warning()
		_mask_worn_time = 0.0

func _start_warning() -> void:
	_is_warning_active = true
	_current_growth_stage = 0
	_growth_timer = 0.0
	visible = true
	
	# Set initial position (off-screen right side)
	demon_container.position = Vector2(get_viewport().get_visible_rect().size.x + 100, 
		get_viewport().get_visible_rect().size.y * 0.3)
	demon_sprite.scale = Vector2(initial_scale, initial_scale)
	demon_sprite.modulate.a = 0.0
	
	# Animate in from right side
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(demon_container, "position:x", 
		get_viewport().get_visible_rect().size.x - 150, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(demon_sprite, "modulate:a", 0.7, 0.5)

func _stop_warning() -> void:
	_is_warning_active = false
	_current_growth_stage = 0
	
	# Animate out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(demon_container, "position:x", 
		get_viewport().get_visible_rect().size.x + 200, 0.3)
	tween.tween_property(demon_sprite, "modulate:a", 0.0, 0.3)
	await tween.finished
	visible = false

func _grow_demon() -> void:
	_current_growth_stage += 1
	
	# Calculate new scale
	var new_scale = initial_scale + (scale_increment * _current_growth_stage)
	
	# Animate growth - SMOOTHER and SLOWER
	# Duration increased to 1.5s to fill most of the interval
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(demon_sprite, "scale", Vector2(new_scale, new_scale), 1.5)
	tween.tween_property(demon_sprite, "modulate:a", min(0.7 + (_current_growth_stage * 0.1), 1.0), 1.5)
	
	# Move closer to center - Smoother
	var move_amount = 50.0
	tween.tween_property(demon_container, "position:x", 
		demon_container.position.x - move_amount, 1.5)
	
	# Subtle floating shake instead of glitchy shake
	_start_continuous_float()
	
	# Check if max growth reached - trigger attack
	if _current_growth_stage >= max_growth_stages:
		await tween.finished
		_trigger_demon_attack()

func _start_continuous_float() -> void:
	# Adds a subtle floating motion
	if demon_sprite.has_meta("floating") and demon_sprite.get_meta("floating"):
		return
		
	demon_sprite.set_meta("floating", true)
	var original_y = demon_sprite.position.y
	
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(demon_sprite, "position:y", original_y - 10, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(demon_sprite, "position:y", original_y + 10, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Superseded by _start_continuous_float for smoother effect
func _shake_demon() -> void:
	pass

func _trigger_demon_attack() -> void:
	_is_attacking = true
	demon_attack_started.emit()
	
	# Pause sanity drain during QTE
	GameManager.set_sanity_drain_paused(true)
	
	# Animate demon rushing toward center
	var center_x = get_viewport().get_visible_rect().size.x / 2 - 100
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(demon_container, "position:x", center_x, 0.3).set_ease(Tween.EASE_IN)
	tween.tween_property(demon_sprite, "scale", Vector2(1.5, 1.5), 0.3)
	await tween.finished
	
	# Trigger camera shake on player
	_trigger_camera_shake()
	
	# Start QTE
	if qte_system != null:
		qte_system.start_demon_qte(damage_per_attack)

func _trigger_camera_shake() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		var players = get_tree().root.find_children("*", "Player", true, false)
		if players.size() > 0:
			player = players[0]
	
	if player != null:
		var camera_comp = player.get_node_or_null("CameraComponent")
		if camera_comp != null and camera_comp.has_method("shake"):
			camera_comp.shake(0.5, 15.0)

func _on_qte_completed(failed_count: int) -> void:
	if not _is_attacking:
		return
	
	var total_damage = failed_count * damage_per_attack
	
	# Resume sanity drain
	GameManager.set_sanity_drain_paused(false)
	
	# Animate demon leaving
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(demon_container, "position:x", 
		get_viewport().get_visible_rect().size.x + 300, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_property(demon_sprite, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	visible = false
	_is_attacking = false
	_is_warning_active = false
	_current_growth_stage = 0
	_mask_worn_time = 0.0
	
	demon_attack_ended.emit(total_damage)
