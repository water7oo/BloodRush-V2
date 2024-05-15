extends Area3D

@onready var gameJuice = get_node("/root/GameJuice")
@onready var enemy_health_label = $health_label
@onready var animationPlayer = $AnimationPlayer
@onready var enemy = get_node("/root/enemy")

var health
var max_health = 10
var taking_damage := false


func _ready():
	#var health = max_health
	#enemy_health_label.text = str(max_health)
	pass
	
func readHealth():
	print("Enemy health is currently " + str(health))


func takeDamageEnemy(health, attack_damage):
	max_health = max_health - attack_damage
	print("ENEMY IS TAKING DAMAGE " + str(max_health))
	taking_damage = true
	await get_tree().create_timer(.15).timeout
	taking_damage = false
	
