extends Area3D

@onready var combatScript = get_node("/root/Combat")
@onready var health = combatScript.health
@onready var health_label = $player_health_label

var max_health = 10
var taking_damage = false
var attack_power = 1.0

## Called when the node enters the scene tree for the first time.
#func _ready():
	#health = max_health
	#print_debug("player: " + str(health))
	#health_label.text = str(health)
	#
	#pass

func _on_area_entered(body):
	if body.name == "enemyBox":
		print("I HAVE SO MUCH TO DO TODAY FUCCCKCKCKCKCKCK")
