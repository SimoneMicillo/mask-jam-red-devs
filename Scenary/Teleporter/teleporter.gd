extends Area3D

@export var target_pos : Vector3 #Target position per il teleport
@export var teleport_masked : bool #Flag per determinare se il teleport avviene per il giocatore se mascherato o no

var counter : int = 0

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("PlayerGroup"):
		body.position = target_pos
		$"../Node3D/CorridorLoop/Furnitures".rand_pos()
		counter += 1
		
		if counter == 1:
			$HelpText.show()
		if counter == 2:
			$HelpText.text = "Really?..."
		if counter == 3:
			$HelpText.text = "Do you need help?..."
		if counter == 4:
			$HelpText.text = "..."
		if counter == 5:
			$HelpText.text = "Uaglio t vuò scetà"
		if counter == 6:
			$HelpText.text = "You may want to search along the walls"
		if counter == 7:
			$HelpText.text = "IT'S ON YOUR RIGHT ->"
		if counter == 8:
			$HelpText.text = "ENABLE YOUR MASK...\nTO YOUR RIGHT ->"
