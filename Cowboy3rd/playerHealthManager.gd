extends Area3D

@onready var gameJuice = get_node("/root/GameJuice")
@onready var health_label = $player_health_label

var health
var max_health = 10
var taking_damage := false


func _ready():
	var health = max_health
	pass


func readHealth():
	print("Player health is currently " + str(health))


func takeDamage(health, attack_damage):
	max_health = max_health - attack_damage
	
	#Time_Scale, Duration
	#gameJuice.hitPause(0.005, 1)
	
	print("Player IS TAKING DAMAGE " + str(max_health))
	taking_damage = true
	await get_tree().create_timer(.15).timeout
	taking_damage = false
