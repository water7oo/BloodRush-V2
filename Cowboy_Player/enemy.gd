extends CharacterBody3D

var player = preload("res://Cowboy3rd/cowboy_3rd_pass.tscn").instantiate()
var Attack_Box = player.get_node("RootNode/Armature/Skeleton3D/AttackBox")
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var enemyBox = $enemyBox

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


	move_and_slide()


func _on_enemy_area_entered(area):
	if area.name == "AttackBox":
		print("fuuuck")
	pass

