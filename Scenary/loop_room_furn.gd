extends Node3D

@export var desk_possible_positions : Array[Vector3]
@export var desk_possible_rotations : Array[Vector3]

@export var chair_possible_positions : Array[Vector3]
@export var chair_possible_rotations : Array[Vector3]

@export var painting_possible_positions : Array[Vector3]

@onready var painting: MeshInstance3D = $Painting
@onready var desk: Node3D = $Desk2
@onready var chair: Node3D = $Chair2
func rand_pos() -> void:
	desk.position = desk_possible_positions.pick_random()
	desk.rotation_degrees = desk_possible_rotations.pick_random()
	
	chair.position = chair_possible_positions.pick_random()
	chair.rotation_degrees = chair_possible_rotations.pick_random()
	
	painting.position = painting_possible_positions.pick_random()
	painting.switch_paintings()
