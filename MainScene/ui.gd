## UI Manager
## Handles HUD display for sanity and mask state.
## Connects to global GameManager signals for decoupled architecture.
extends CanvasLayer


func _ready() -> void:
	# Connect to global GameManager signals
	GameManager.sanity_changed.connect(_on_sanity_changed)
	GameManager.mask_state_changed.connect(_on_mask_state_changed)
	
	# Initialize UI to current state
	_on_sanity_changed(GameManager.current_sanity)
	_on_mask_state_changed(GameManager.is_mask_on)


func _on_sanity_changed(new_sanity: float) -> void:
	$sanity.text = "Sanity = " + str(int(new_sanity))
	
	var max_san: float = GameManager.max_sanity
	
	if new_sanity >= max_san:
		get_tree().create_tween().tween_property($sanity, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	elif new_sanity < max_san:
		if new_sanity <= max_san / 3.0:
			get_tree().create_tween().tween_property($sanity, "modulate", Color(1.0, 0.0, 0.0, 1.0), 0.25)
		elif new_sanity <= max_san / 2.0:
			get_tree().create_tween().tween_property($sanity, "modulate", Color(1.0, 1.0, 0.0, 1.0), 0.25)
		else:
			get_tree().create_tween().tween_property($sanity, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)


func _on_mask_state_changed(is_active: bool) -> void:
	if is_active:
		$maskOnOff.text = "Mask: ON"
		# Show centered mask text with fade in
		$maskCenterText.visible = true
		var tween: Tween = create_tween()
		tween.tween_property($maskCenterText, "modulate:a", 1.0, 0.3).from(0.0)
	else:
		$maskOnOff.text = "Mask: OFF"
		# Hide centered mask text with fade out
		var tween: Tween = create_tween()
		tween.tween_property($maskCenterText, "modulate:a", 0.0, 0.3)
		await tween.finished
		$maskCenterText.visible = false
