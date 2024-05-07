class_name Enemy
extends CharacterBody3D

@onready var playerHealthMan = get_node("/root/PlayerHealthManager")
@onready var enemyHealthMan = get_node("/root/EnemyHealthManager")


var enemy_default_mesh = preload("res://Cowboy_Player/Enemy.tres")
var enemy_damage_mesh = preload("res://Cowboy_Player/Enemy_Hit.tres")
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var enemyBox = $enemyBox
@onready var enemy_health_label = $health_label


var attack_power = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta


	move_and_slide()
	
	

#Hurtbox
func _on_enemy_area_entered(area):
	if area.has_method("takeDamage"):
		playerHealthMan.takeDamage(playerHealthMan.health , attack_power)
		pass
	
