## Klotski Puzzle
## A sliding block puzzle where the player must move pieces to free the Shred
## Classic Klotski-style puzzle game
extends CanvasLayer
class_name KlotskiPuzzle

signal puzzle_completed()

@export var puzzle_id: String = "klotski_1"  # Unique ID for tracking completion

# Grid configuration - LARGER SIZE
const GRID_WIDTH: int = 4
const GRID_HEIGHT: int = 5
const CELL_SIZE: int = 120  # Bigger cells!
const EXIT_ROW: int = 4
const EXIT_COL_START: int = 1

# Wood color palette
const WOOD_COLORS: Array[Color] = [
	Color(0.55, 0.35, 0.20),  # Dark wood
	Color(0.65, 0.45, 0.25),  # Medium wood
	Color(0.60, 0.40, 0.22),  # Brown wood
	Color(0.50, 0.32, 0.18),  # Walnut
	Color(0.58, 0.38, 0.20),  # Oak
	Color(0.52, 0.34, 0.19),  # Mahogany
]
const FRAGMENT_COLOR: Color = Color(1.0, 0.85, 0.0)  # Golden

# Piece types
enum PieceType { SINGLE, HORIZONTAL, VERTICAL, LARGE, FRAGMENT }

# Piece data structure
class PuzzlePiece:
	var id: String
	var type: PieceType
	var width: int
	var height: int
	var grid_x: int
	var grid_y: int
	var color: Color
	var control: Control
	
	func _init(p_id: String, p_type: PieceType, p_x: int, p_y: int, p_color: Color):
		id = p_id
		type = p_type
		grid_x = p_x
		grid_y = p_y
		color = p_color
		match type:
			PieceType.SINGLE:
				width = 1
				height = 1
			PieceType.HORIZONTAL:
				width = 2
				height = 1
			PieceType.VERTICAL:
				width = 1
				height = 2
			PieceType.LARGE:
				width = 2
				height = 2
			PieceType.FRAGMENT:
				width = 2
				height = 2

# State
var _pieces: Array[PuzzlePiece] = []
var _grid: Array = []
var _selected_piece: PuzzlePiece = null
var _drag_start_pos: Vector2 = Vector2.ZERO
var _drag_start_grid: Vector2i = Vector2i.ZERO
var _is_active: bool = false
var _is_solved: bool = false
var _is_dragging: bool = false
var _showing_intro: bool = false

# UI References
@onready var puzzle_panel: Panel = $PuzzlePanel
@onready var puzzle_container: Control = $PuzzlePanel/PuzzleContainer
@onready var title_label: Label = $PuzzlePanel/TitleLabel
@onready var hint_label: Label = $PuzzlePanel/HintLabel
@onready var close_button: Button = $PuzzlePanel/CloseButton
@onready var intro_panel: Panel = $IntroPanel

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_initialize_grid()
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func _initialize_grid() -> void:
	_grid.clear()
	for y in range(GRID_HEIGHT):
		var row: Array = []
		for x in range(GRID_WIDTH):
			row.append(null)
		_grid.append(row)

func _setup_default_puzzle() -> void:
	for piece in _pieces:
		if piece.control:
			piece.control.queue_free()
	_pieces.clear()
	_initialize_grid()
	
	# EASIER Layout - Fragment in original position, all other blocks are 1x1
	_add_piece("F", PieceType.FRAGMENT, 1, 0, FRAGMENT_COLOR)  # Golden Fragment - original position
	_add_piece("O", PieceType.VERTICAL, 0, 0, WOOD_COLORS[1])
	#_add_piece("A", PieceType.SINGLE, 0, 1, WOOD_COLORS[0])
	_add_piece("B", PieceType.SINGLE, 0, 2, WOOD_COLORS[1])
	_add_piece("C", PieceType.SINGLE, 0, 3, WOOD_COLORS[2])
	#_add_piece("D", PieceType.SINGLE, 0, 4, WOOD_COLORS[3])
	#_add_piece("E", PieceType.SINGLE, 3, 0, WOOD_COLORS[4])
	#_add_piece("G", PieceType.SINGLE, 3, 1, WOOD_COLORS[5])
	_add_piece("E", PieceType.VERTICAL, 3, 0, WOOD_COLORS[1])

	_add_piece("H", PieceType.SINGLE, 3, 2, WOOD_COLORS[0])
	_add_piece("I", PieceType.SINGLE, 3, 3, WOOD_COLORS[1])
	#_add_piece("J", PieceType.SINGLE, 3, 4, WOOD_COLORS[5])
	_add_piece("K", PieceType.SINGLE, 1, 2, WOOD_COLORS[0])
	_add_piece("L", PieceType.SINGLE, 1, 3, WOOD_COLORS[1])
	_add_piece("M", PieceType.SINGLE, 2, 2, WOOD_COLORS[0])
	_add_piece("N", PieceType.SINGLE, 2, 3, WOOD_COLORS[1])
	# All blocks are 1x1, easier to move around the Shred!

func _add_piece(id: String, type: PieceType, grid_x: int, grid_y: int, color: Color) -> void:
	var piece = PuzzlePiece.new(id, type, grid_x, grid_y, color)
	_pieces.append(piece)
	
	for dy in range(piece.height):
		for dx in range(piece.width):
			_grid[grid_y + dy][grid_x + dx] = piece
	
	_create_piece_visual(piece)

func _create_piece_visual(piece: PuzzlePiece) -> void:
	var control = Panel.new()
	control.custom_minimum_size = Vector2(piece.width * CELL_SIZE - 6, piece.height * CELL_SIZE - 6)
	control.size = control.custom_minimum_size
	control.position = Vector2(piece.grid_x * CELL_SIZE + 3, piece.grid_y * CELL_SIZE + 3)
	
	var style = StyleBoxFlat.new()
	style.bg_color = piece.color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	
	# Wood grain effect - darker border
	if piece.id != "F":
		style.border_color = piece.color.darkened(0.3)
		# Add wood texture lines
		style.shadow_color = piece.color.darkened(0.15)
		style.shadow_size = 2
	else:
		# Golden Shred - special styling
		style.border_color = Color(1.0, 0.6, 0.0)
		style.shadow_color = Color(1.0, 0.9, 0.5, 0.5)
		style.shadow_size = 8
		
		# Add F label only for Fragment
		var label = Label.new()
		label.text = "F"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 64)
		label.add_theme_color_override("font_color", Color(0.4, 0.2, 0.0))
		label.add_theme_constant_override("outline_size", 4)
		label.add_theme_color_override("font_outline_color", Color(1.0, 0.95, 0.7))
		label.anchors_preset = Control.PRESET_FULL_RECT
		control.add_child(label)
	
	control.add_theme_stylebox_override("panel", style)
	control.mouse_filter = Control.MOUSE_FILTER_PASS
	
	piece.control = control
	puzzle_container.add_child(control)

func _input(event: InputEvent) -> void:
	if not _is_active or _is_solved or _showing_intro:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.global_position)
			else:
				_end_drag()
	
	elif event is InputEventMouseMotion and _is_dragging:
		_update_drag(event.global_position)

func _start_drag(mouse_pos: Vector2) -> void:
	var local_pos = puzzle_container.get_global_transform().affine_inverse() * mouse_pos
	var grid_x = int(local_pos.x / CELL_SIZE)
	var grid_y = int(local_pos.y / CELL_SIZE)
	
	if grid_x < 0 or grid_x >= GRID_WIDTH or grid_y < 0 or grid_y >= GRID_HEIGHT:
		return
	
	var piece = _grid[grid_y][grid_x]
	if piece != null:
		_selected_piece = piece
		_is_dragging = true
		_drag_start_pos = local_pos
		_drag_start_grid = Vector2i(piece.grid_x, piece.grid_y)
		if piece.control:
			piece.control.move_to_front()
			# Visual feedback - slight scale up
			var tween = create_tween()
			tween.tween_property(piece.control, "scale", Vector2(1.05, 1.05), 0.1)

func _update_drag(mouse_pos: Vector2) -> void:
	if _selected_piece == null or not _is_dragging:
		return
	
	var local_pos = puzzle_container.get_global_transform().affine_inverse() * mouse_pos
	var delta = local_pos - _drag_start_pos
	
	# More responsive - lower threshold for movement
	var threshold = CELL_SIZE * 0.4
	
	var move_x = 0
	var move_y = 0
	
	if abs(delta.x) > threshold:
		move_x = 1 if delta.x > 0 else -1
	if abs(delta.y) > threshold:
		move_y = 1 if delta.y > 0 else -1
	
	# Only move in one direction at a time
	if move_x != 0 and move_y != 0:
		if abs(delta.x) > abs(delta.y):
			move_y = 0
		else:
			move_x = 0
	
	if move_x != 0 or move_y != 0:
		var new_x = _selected_piece.grid_x + move_x
		var new_y = _selected_piece.grid_y + move_y
		
		new_x = clampi(new_x, 0, GRID_WIDTH - _selected_piece.width)
		new_y = clampi(new_y, 0, GRID_HEIGHT - _selected_piece.height)
		
		if _can_move_to(_selected_piece, new_x, new_y):
			_move_piece(_selected_piece, new_x, new_y)
			_drag_start_pos = local_pos
			_drag_start_grid = Vector2i(new_x, new_y)

func _end_drag() -> void:
	if _selected_piece != null:
		if _selected_piece.control:
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(_selected_piece.control, "scale", Vector2(1.0, 1.0), 0.1)
			tween.tween_property(_selected_piece.control, "position", 
				Vector2(_selected_piece.grid_x * CELL_SIZE + 3, _selected_piece.grid_y * CELL_SIZE + 3), 0.1)
		
		_check_win_condition()
	
	_selected_piece = null
	_is_dragging = false

func _can_move_to(piece: PuzzlePiece, new_x: int, new_y: int) -> bool:
	var dx = new_x - piece.grid_x
	var dy = new_y - piece.grid_y
	
	if abs(dx) > 1 or abs(dy) > 1:
		return false
	if dx != 0 and dy != 0:
		return false
	if dx == 0 and dy == 0:
		return true
	
	for py in range(piece.height):
		for px in range(piece.width):
			var check_x = new_x + px
			var check_y = new_y + py
			
			if check_x < 0 or check_x >= GRID_WIDTH or check_y < 0 or check_y >= GRID_HEIGHT:
				return false
			
			var occupant = _grid[check_y][check_x]
			if occupant != null and occupant != piece:
				return false
	
	return true

func _move_piece(piece: PuzzlePiece, new_x: int, new_y: int) -> void:
	for dy in range(piece.height):
		for dx in range(piece.width):
			_grid[piece.grid_y + dy][piece.grid_x + dx] = null
	
	piece.grid_x = new_x
	piece.grid_y = new_y
	
	for dy in range(piece.height):
		for dx in range(piece.width):
			_grid[new_y + dy][new_x + dx] = piece
	
	if piece.control:
		piece.control.position = Vector2(new_x * CELL_SIZE + 3, new_y * CELL_SIZE + 3)

func _check_win_condition() -> void:
	for piece in _pieces:
		if piece.id == "F":
			if piece.grid_x == EXIT_COL_START and piece.grid_y == GRID_HEIGHT - piece.height:
				_solve_puzzle()
			return

func _solve_puzzle() -> void:
	_is_solved = true
	
	# Register fragment collection with GameManager
	GameManager.collect_fragment(puzzle_id)
	
	for piece in _pieces:
		if piece.id == "F" and piece.control:
			var tween = create_tween()
			tween.tween_property(piece.control, "position:y", 
				piece.control.position.y + CELL_SIZE * 2, 0.5).set_ease(Tween.EASE_IN)
			tween.tween_property(piece.control, "modulate:a", 0.0, 0.3)
			await tween.finished
	
	if hint_label:
		var collected = GameManager.get_fragments_collected()
		var total = GameManager.get_total_fragments()
		hint_label.text = "SHREDS OBTAINED! (%d/%d)" % [collected, total]
		hint_label.modulate = Color(0.2, 1.0, 0.2)
	
	await get_tree().create_timer(2.0).timeout
	
	puzzle_completed.emit()
	close_puzzle()

func open_puzzle() -> void:
	_is_active = true
	_is_solved = false
	_showing_intro = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	get_tree().paused = true
	
	# Show intro dialogue first
	_show_intro()

func _show_intro() -> void:
	if puzzle_panel:
		puzzle_panel.visible = false
	
	# Create intro panel dynamically if not exists
	if intro_panel == null:
		intro_panel = Panel.new()
		intro_panel.name = "IntroPanel"
		add_child(intro_panel)
	
	intro_panel.visible = true
	
	# Position at BOTTOM CENTER
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_width = 900.0
	var panel_height = 120.0
	intro_panel.size = Vector2(panel_width, panel_height)
	intro_panel.position = Vector2(
		(viewport_size.x - panel_width) / 2,
		viewport_size.y - panel_height - 40
	)
	
	# Clear and add content
	for child in intro_panel.get_children():
		child.queue_free()
	
	# Wait one frame to ensure children are freed
	await get_tree().process_frame
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.06, 0.95)
	style.set_corner_radius_all(10)
	style.set_border_width_all(3)
	style.border_color = Color(0.5, 0.35, 0.2)
	intro_panel.add_theme_stylebox_override("panel", style)
	
	# Simple centered container
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_panel.add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	center.add_child(vbox)
	
	var text_label = Label.new()
	text_label.text = "It looks like there's a shred stuck in the wall... I'll try to free it!"
	text_label.add_theme_font_size_override("font_size", 24)
	text_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(text_label)
	
	var continue_btn = Button.new()
	continue_btn.text = "Continue"
	continue_btn.custom_minimum_size = Vector2(150, 40)
	continue_btn.pressed.connect(_on_intro_continue)
	vbox.add_child(continue_btn)

func _on_intro_continue() -> void:
	_showing_intro = false
	if intro_panel:
		intro_panel.visible = false
	if puzzle_panel:
		puzzle_panel.visible = true
	
	_setup_default_puzzle()
	
	if hint_label:
		hint_label.text = "Drag the blocks to release the shred!"
		hint_label.modulate = Color.WHITE

func close_puzzle() -> void:
	_is_active = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_close_pressed() -> void:
	if not _is_solved:
		close_puzzle()
