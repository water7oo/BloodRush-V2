extends Node3D


var game_paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pause_game(delta)
	pass
	

func pause_game(delta):
		if Input.is_action_just_pressed("pause_button"):
			if game_paused:
				print_debug("Unpausing game")
				get_tree().paused = false
				game_paused = false
			else:
				print_debug("Pausing game")
				get_tree().paused = true
				game_paused = true
