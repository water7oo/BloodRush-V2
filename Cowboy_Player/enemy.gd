extends CharacterBody3D

var player = preload("res://Cowboy3rd/cowboy_3rd_pass.tscn").instantiate()
var Attack_Box = player.get_node("RootNode/Armature/Skeleton3D/AttackBox")
var enemy_default_mesh = preload("res://Cowboy_Player/Enemy.tres")
var enemy_damage_mesh = preload("res://Cowboy_Player/Enemy_Hit.tres")
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var max_health = 10
var taking_damage := false
var attack_damage = 1
var health 
@onready var enemyBox = $enemyBox
@onready var enemy_health_label = $health_label

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	health = max_health
	enemy_health_label.text = str(health)

func _physics_process(delta):
	# Add the gravity.
	#print_debug("Enemy: " + str(health))
	if not is_on_floor():
		velocity.y -= gravity * delta


	move_and_slide()


func _on_enemy_area_entered(area):
	if area.name == "AttackBox":
		print("fuuuck")
	pass




func damage(attack_damage):
	health -= attack_damage
	
	if health <= 0:
		print("DIED")
	
	taking_damage = true


func hit_stop(timeScale, duration):
		Engine.time_scale = timeScale
		var timer = get_tree().create_timer(timeScale * duration)
		await timer.timeout
		Engine.time_scale = 1
	
	

func _on_enemy_box_body_entered(body):
	if body.has_method("damage"):
		body.damage(attack_damage)
		hit_stop(0.005, 1.5)
		$RootNode/Armature/Skeleton3D/Cowboy_001.surface_set_material(0, enemy_damage_mesh)
		print("Enemy damaged player")
