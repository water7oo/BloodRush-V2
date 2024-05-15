class_name Enemy
extends CharacterBody3D

@onready var playerHealthMan = get_node("/root/PlayerHealthManager")
@onready var enemyHealthMan = get_node("/root/EnemyHealthManager")
@onready var gameJuice = get_node("/root/GameJuice")
@onready var followcam = get_node("/root/FollowCam")


var enemy_default_mesh = preload("res://Cowboy_Player/Enemy.tres")
var enemy_damage_mesh = preload("res://Cowboy_Player/Enemy_Hit.tres")
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var ENEMY_DECELERATION = 10.0

@onready var enemyBox = $enemyBox
@onready var enemy_health_label = $health_label
var attack_processing = false

var attack_power = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	velocity.x = move_toward(velocity.x, 0, ENEMY_DECELERATION * delta)
	velocity.z = move_toward(velocity.z, 0, ENEMY_DECELERATION * delta)

	move_and_slide()



func animations():
	if enemyHealthMan.takeDamageEnemy:
		$AnimationTree.set("parameters/Blend2/blend_amount", 1)
		await get_tree().create_timer(0.5).timeout
		$AnimationTree.set("parameters/Blend2/blend_amount", 0)

func pause():
	process_mode = PROCESS_MODE_DISABLED

func unpause():
	process_mode = PROCESS_MODE_INHERIT

#Hurtbox
#If the player touches this make them have hit pause but also put enemy in hit pause by timescale
func _on_enemy_area_entered(area):
	if area.has_method("takeDamage") and not attack_processing:
		print(enemyBox.monitoring)
		attack_processing = true
		enemyBox.monitoring = true
		playerHealthMan.takeDamage(playerHealthMan.health, attack_power)
		pause()
		area.get_parent().pause()
		
		
		await get_tree().create_timer(0.1).timeout
		unpause()
		area.get_parent().unpause()
		
		
		gameJuice.knockback(area.get_parent(), enemyBox, 10)
		
		animations()
		
		attack_processing = false
		enemyBox.monitoring = false
		await get_tree().create_timer(1).timeout
		enemyBox.monitoring = true
		print(enemyBox.monitoring)
		
	if area.name == "AttackBox" && area.monitoring == true:
		print("Player hit me")
	
func _on_hurt_box_area_entered(area):
	pass # Replace with function body.

