extends Node
#Adds flavor to the game and makes stuff feel good to hit

var impact = true
func _ready():
	pass
	

func hitPause(timeScale, duration):
		Engine.time_scale = timeScale
		var timer = get_tree().create_timer(timeScale * duration)
		await timer.timeout
		Engine.time_scale = 1
		print("HIT PAUSE")
		impact = true
	

func knockback():
	print("KnockBack")
	
	pass
