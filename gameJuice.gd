extends Node
#Adds flavor to the game and makes stuff feel good to hit

@onready var followcam = get_node("/root/FollowCam")

var impact = true
func _ready():
	pass
	

func hitPause(timeScale, duration):
		Engine.time_scale = timeScale
		var timer = get_tree().create_timer(timeScale * duration)
		await timer.timeout
		Engine.time_scale = 1
		followcam.applyShake()
		print("HIT PAUSE")
		impact = true



func knockback(enemy):
	print("knockback HARD")
	var pushback_direction = Vector3(-1,0,0)
	
	var pushback_force = 1000
	
	if enemy == CharacterBody3D:
		var character_body = Enemy
		print("OBJECT HIT IS CHARACTERBODY3D")
		
		var pushback_velocity = pushback_direction.normalized() * pushback_force
		
		character_body.set_linear_velocity(pushback_velocity)
	
	pass
