class_name Enemy
extends CharacterBody3D

@onready var playerHealthMan = get_node("/root/PlayerHealthManager")
@onready var enemyHealthMan = get_node("/root/EnemyHealthManager")
@onready var gameJuice = get_node("/root/GameJuice")


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
	
	


func animations():
	if enemyHealthMan.takeDamageEnemy:
		$AnimationPlayer.play("TPOSE")

func pause():
	process_mode = PROCESS_MODE_DISABLED

func unpause():
	process_mode = PROCESS_MODE_INHERIT

#Hurtbox
#If the player touches this make them have hit pause but also put enemy in hit pause by timescale
func _on_enemy_area_entered(area):
	if area.has_method("takeDamage"):
		area.get_parent().pause()
		gameJuice.hitPause(0.1, 1)
		await get_tree().create_timer(1).timeout
		
		area.get_parent().unpause()
		playerHealthMan.takeDamage(playerHealthMan.health , attack_power)
		
		#Put function here that pushes area away somehow
		
		animations()
		pass
	
	

