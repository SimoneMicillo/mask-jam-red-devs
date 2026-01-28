## KlotskiPiece
## Represents a single draggable piece in the Klotski puzzle
extends Control
class_name KlotskiPiece

signal piece_moved(piece: KlotskiPiece, new_grid_pos: Vector2i)
signal drag_started(piece: KlotskiPiece)
signal drag_ended(piece: KlotskiPiece)

# Piece properties
@export var piece_id: int = 0
@export var grid_width: int = 1  # Width in grid cells
@export var grid_height: int = 1  # Height in grid cells
@export var is_target_piece: bool = false  # Is this the piece that needs to reach the exit?

# Grid position
var grid_position: Vector2i = Vector2i(0, 0)

# Visual properties
@export var piece_color: Color = Color(0.8, 0.3, 0.3, 1.0)
@export var target_color: Color = Color(1.0, 0.2, 0.2, 1.0)
@export var hover_color: Color = Color(0.9, 0.5, 0.5, 1.0)

# Dragging state
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

# References
var grid_cell_size: int = 80
var puzzle_controller = null

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Setup visual
	_update_visual()
	
	# Connect mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func initialize(id: int, width: int, height: int, grid_pos: Vector2i, cell_size: int, is_target: bool = false) -> void:
	piece_id = id
	grid_width = width
	grid_height = height
	grid_position = grid_pos
	grid_cell_size = cell_size
	is_target_piece = is_target
	
	# Set size based on grid dimensions
	custom_minimum_size = Vector2(grid_width * grid_cell_size, grid_height * grid_cell_size)
	size = custom_minimum_size
	
	_update_visual()
	_update_position_from_grid()


func _update_visual() -> void:
	if color_rect == null:
		return
	
	# Set size
	color_rect.custom_minimum_size = custom_minimum_size
	color_rect.size = custom_minimum_size
	
	# Set color
	if is_target_piece:
		color_rect.color = target_color
	else:
		color_rect.color = piece_color
	
	# Update label
	if label:
		label.text = str(piece_id) if piece_id > 0 else ""
		label.size = custom_minimum_size


func _update_position_from_grid() -> void:
	position = Vector2(grid_position.x * grid_cell_size, grid_position.y * grid_cell_size)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_end_drag()
	
	elif event is InputEventMouseMotion:
		if is_dragging:
			_update_drag(event.position)


func _start_drag(mouse_pos: Vector2) -> void:
	is_dragging = true
	drag_offset = mouse_pos
	original_position = position
	z_index = 10  # Bring to front
	
	drag_started.emit(self)


func _update_drag(mouse_pos: Vector2) -> void:
	if not is_dragging:
		return
	
	# Calculate new position
	var global_mouse_pos: Vector2 = get_global_mouse_position()
	var parent_offset: Vector2 = get_parent().global_position if get_parent() else Vector2.ZERO
	var new_pos: Vector2 = global_mouse_pos - parent_offset - drag_offset
	
	position = new_pos


func _end_drag() -> void:
	if not is_dragging:
		return
	
	is_dragging = false
	z_index = 0
	
	# Snap to grid
	var new_grid_pos: Vector2i = Vector2i(
		roundi(position.x / float(grid_cell_size)),
		roundi(position.y / float(grid_cell_size))
	)
	
	drag_ended.emit(self)
	
	# Notify controller to validate move
	if puzzle_controller:
		puzzle_controller.validate_piece_move(self, new_grid_pos)
	else:
		# If no controller, just snap back
		_update_position_from_grid()


func set_grid_position(new_pos: Vector2i) -> void:
	grid_position = new_pos
	_update_position_from_grid()
	piece_moved.emit(self, new_pos)


func snap_back_to_grid() -> void:
	# Animate back to grid position
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", Vector2(grid_position.x * grid_cell_size, grid_position.y * grid_cell_size), 0.2)


func _on_mouse_entered() -> void:
	if not is_dragging and color_rect:
		color_rect.color = hover_color


func _on_mouse_exited() -> void:
	if not is_dragging and color_rect:
		if is_target_piece:
			color_rect.color = target_color
		else:
			color_rect.color = piece_color
