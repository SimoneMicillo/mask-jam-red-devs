extends TextureProgressBar

func _ready() -> void:
	value = GameManager.max_sanity
	step = GameManager.sanity_drain_rate
	GameManager.sanity_changed.connect(updateUI)

func updateUI(curr_san) -> void:
	value = curr_san
