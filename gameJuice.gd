extends Node
#Adds flavor to the game and makes stuff feel good to hit

@onready var followcam = get_node("/root/FollowCam")
var knockback_direction = Vector3(-1, 0, 0)  # Example knockback direction (left)
var knockback_distance = 2  # Example knockback distance
var knockback_force = 1000  # Example knockback force


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



func knockback(enemy, target_attack, knockback_force):
	# Get the global transforms of the enemy and the target attack box
	var enemy_global_transform = enemy.global_transform
	var target_attack_global_transform = target_attack.global_transform

	# Calculate the world-space position of the target attack box
	var target_attack_position = target_attack_global_transform.origin

	# Calculate the world-space position of the enemy
	var enemy_position = enemy_global_transform.origin

	# Calculate the direction from the enemy to the target attack box
	var knockback_direction = (enemy_position - target_attack_position).normalized()

	# Calculate the knockback velocity
	var knockback_velocity = knockback_direction * knockback_force
	
	# Apply the knockback velocity to the enemy's velocity
	enemy.velocity += knockback_velocity
