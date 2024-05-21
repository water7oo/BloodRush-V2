class_name Player
extends CharacterBody3D

@onready var combatScript = get_node("/root/Combat")
@onready var health = combatScript.health
@onready var gameJuice = get_node("/root/GameJuice")
@onready var followcam = get_node("/root/FollowCam")

var last_ground_position = Vector3()
var waveEffect = preload("res://DustWave2.tscn")
var AirWave = preload("res://AirDustWave2.tscn")
var GroundSpark = preload("res://FX/GroundSPark.tscn")

@onready var AirWavePos = $AirWavePos

@onready var playerHealthMan = get_node("/root/PlayerHealthManager")

@onready var enemyHealthMan = get_node("/root/EnemyHealthManager")



var camera = preload("res://Cowboy_Player/PlayerCamera.tscn").instantiate()
var spring_arm_pivot = camera.get_node("SpringArmPivot")
var spring_arm = camera.get_node("SpringArmPivot/SpringArm3D")
@onready var dodge_node_timer = $Dodge_Cooldown
@onready var dodge_cooldown_label = $Dodge_Cooldown_Label
@onready var blend_space = $AnimationTree.get('parameters/Combat/Ground_Blend/blend_position')
@onready var blend_space2 = $AnimationTree.get('parameters/Combat/MoveStrafe/blend_position')
@onready var Stamina_bar = $"UI Cooldowns"
@onready var health_bar = $player_health


var current_blend_amount = 0.0
var target_blend_amount = 0.0
var blend_lerp_speed = 10.0  # Adjust the speed of blending


@onready var armature = $RootNode/Armature/Skeleton3D
@onready var jump_wave = get_tree().get_nodes_in_group("Jump_wave")
@onready var dust_trail = get_tree().get_nodes_in_group("dust_trail")
@onready var jump_dust = get_tree().get_nodes_in_group("jump_dust")
@onready var move_dust = get_tree().get_nodes_in_group("move_dust")
@onready var burst_dust = get_tree().get_nodes_in_group("burst_dust")
@onready var wall_wave = get_tree().get_nodes_in_group("wall_wave")
@onready var punch_dust = get_tree().get_nodes_in_group("punch_dust")
@onready var InputBuffer = get_node("/root/InputBuffer")

#Basic Movement
@export var mouse_sensitivity = 0.005
@export var joystick_sensitivity = 0.005
@export var BASE_SPEED = 3
@export var MAX_SPEED = 7
@export var  STAMINA_DEPLETED_SPEED = 1
var SPEED = BASE_SPEED
var target_speed = BASE_SPEED
var current_speed = 0.0

var is_moving = false

@export var JUMP_VELOCITY = 8
@export var SHORT_JUMP = 4
@export var LONG_JUMP = 8
@export var RUNJUMP_MULTIPLIER = 1.3
var jump_timer = 0.0
var jump_tap_timer = 0.1
var jump_height = 128
var jump_counter = 1

#Acceleration and Speed
var can_move = true
@export var ACCELERATION = 5.0 #the higher the value the faster the acceleration
@export var DECELERATION = 25.0 #the lower the value the slippier the stop
@export var BASE_ACCELERATION = 5
@export var BASE_DECELERATION = 15.0 
@export var DASH_ACCELERATION = 20
@export var DASH_DECELERATION = 20
var DASH_MAX_SPEED = BASE_SPEED * 3

@export var stamina = 250
@export var sprinting_deplete_rate = 5
@export var sprinting_refill_rate = 10
@export var sprinting_refill_rate_zero = 5
var is_dodging = false
var can_dodge = true
var can_sprint = true
var dash_timer = 0.0
var dodge_cooldown_timer = 0.0
@export var DODGE_SPEED = 30
@export var dash_duration = 0.04
@export var SECOND_DASH_ACCELERATION = 300
@export var SECOND_DASH_DECELERATION = 25
var INITIAL_DASH_ACCELERATION = ACCELERATION
var INITIAL_DASH_DECELERATION = DECELERATION
var INITIAL_MAX_SPEED = MAX_SPEED
var SECOND_MAX_SPEED = DASH_MAX_SPEED * 2
var is_second_sprint = false

@export var DODGE_ACCELERATION = 100
@export var DODGE_DECELERATION = 5


var WALL_JUMP_VELOCITY_MULTIPLIER = 2.5

var air_time = 0.0
var air_timer = 0.0
var sprint_timer = 0.0


var landing_animation_threshold = 1.0
var WALL_STAY_DURATION = 0.5  # Adjust this value to control how long the player stays on the wall after a jump
var wall_stay_timer = 0.0
var ORIGINAL_JUMP_VEL = JUMP_VELOCITY
var RUN_JUMP_VELOCITY = JUMP_VELOCITY * RUNJUMP_MULTIPLIER
var LERP_VAL = 0.2
var DODGE_LERP_VAL = 1
var wall_jump_position = Vector3.ZERO

var custom_gravity = 25.0 #The lower the value the floatier
var sprinting = false
var dodging = false
var dodge_timer = 0.0
@export var dodge_cooldown = .1
var is_in_air = false
var can_jump = true

var is_sprinting = false
var light_attack1 = false
var light_attack2 = false
var medium_attack1 = false
var landing_position = Vector3.ZERO
var can_wall_jump = true
var has_wall_jumped = false
var attack_proccessing = false

var fall = Vector3()
var wall_normal
var direction = Vector3()

#Attacking

@onready var Attack_Box = $RootNode/Armature/Skeleton3D/BoneAttachment3D/AttackBox
@onready var Hurt_Box = $HurtBox
var attacklight_1 = Input.is_action_just_pressed("attack_light_1")
var attacklight1_timer = 0.0
var attack_cooldown = 0.0
var attacklight2_timer = 0.0
var attack_signal = false
var can_attack = true


# Hitbox variables
var hitbox = null
var hitbox_active = false
var hitbox_duration = 0.2  # Adjust the duration of the hitbox here
var is_attacking = false
var jumping = Input.is_action_pressed("move_jump")


var attack_power = 1.0

var current_ground_spark = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()

	if event is InputEventMouseMotion:

		var rotation_x = spring_arm_pivot.rotation.x - event.relative.y * mouse_sensitivity
		var rotation_y = spring_arm_pivot.rotation.y - event.relative.x * mouse_sensitivity

		rotation_x = clamp(rotation_x, deg_to_rad(-60), deg_to_rad(30))

		spring_arm_pivot.rotation.x = rotation_x
		spring_arm_pivot.rotation.y = rotation_y
		
	if Input.is_action_pressed("cam_down"):
		spring_arm_pivot.rotation.x -= joystick_sensitivity 
	if Input.is_action_pressed("cam_up"):
		spring_arm_pivot.rotation.x += joystick_sensitivity 
	if Input.is_action_pressed("cam_right"):
		spring_arm_pivot.rotation.y -= joystick_sensitivity 
	if Input.is_action_pressed("cam_left"):
		spring_arm_pivot.rotation.y += joystick_sensitivity 

func _proccess_movement(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	
	if direction && can_move == true:
		is_moving = true
		if current_speed < target_speed:
			current_speed = move_toward(current_speed, target_speed, ACCELERATION * delta)
		else:
			current_speed = move_toward(current_speed, target_speed, DECELERATION * delta)
	
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		if direction && !is_sprinting && is_on_floor():
			target_blend_amount = 0.0
			current_blend_amount = lerp(current_blend_amount, target_blend_amount, blend_lerp_speed * delta)
			$AnimationTree.set("parameters/Ground_Blend/blend_amount", 0)
		else:
			target_blend_amount = -1.0
		
#		if is_sprinting:
#			ACCELERATION = ACCELERATION * 1.5
#			DECELERATION = DECELERATION * 1
#		else:
#			ACCELERATION = BASE_ACCELERATION
#			DECELERATION = BASE_DECELERATION

	
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), .07)
		
	elif !direction && is_on_floor():
			is_moving = false
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
			velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)
			current_speed = sqrt(velocity.x * velocity.x + velocity.z * velocity.z)
			$AnimationTree.set("parameters/Ground_Blend/blend_amount", -1) 
			$AnimationTree.set("parameters/Ground_Blend2/blend_amount", -1)
			$AnimationTree.set("parameters/Jump_Blend/blend_amount", -1)
			$AnimationTree.set("parameters/Blend3/blend_amount", -1)  

	for node in dust_trail:
			var particle_emitter = node.get_node("Dust")
			if particle_emitter && input_dir != Vector2.ZERO && is_on_floor():
				var should_emit_particles = is_sprinting && !is_in_air && current_speed >= MAX_SPEED || dodging
				particle_emitter.set_emitting(should_emit_particles)
				
			if jumping || velocity.y > 0:
				particle_emitter.set_emitting(false)
				
	for node in jump_dust:
		var particle_emitter = node.get_node("jump_dust")
		if particle_emitter && Input.is_action_just_pressed("move_jump"):
			particle_emitter.set_emitting(true)
		else:
			particle_emitter.set_emitting(false)

	for node in move_dust:
		var particle_emitter = node.get_node("move_dust")
		if particle_emitter && is_on_floor() && direction && !sprinting:
			particle_emitter.set_emitting(true)
		else:
			particle_emitter.set_emitting(false)
			
			
	for node in burst_dust:
		var particle_emitter = node.get_node("burst_dust")
		if particle_emitter && is_on_floor() && dodging && Stamina_bar.value >= 20 && direction:
			particle_emitter.set_emitting(true)
		else:
			particle_emitter.set_emitting(false)


func GroundSParkEffect():
		var GroundSpark = GroundSpark.instantiate()
		get_parent().add_child(GroundSpark)
		GroundSpark.global_transform.origin = last_ground_position
		GroundSpark.global_transform.basis = global_transform.basis
		await get_tree().create_timer(.4).timeout
		GroundSpark.queue_free()
		

func AirWaveEffect():
		var AirWave = AirWave.instantiate()
		get_parent().add_child(AirWave)
		AirWave.global_transform.origin = last_ground_position + Vector3(0,1,0)
		await get_tree().create_timer(.4).timeout
		AirWave.queue_free()
		
func GeneralwaveEffect():
		# Instantiate the wind shockwave at the last ground position
		var waveEffect = waveEffect.instantiate()
		get_parent().add_child(waveEffect)
		waveEffect.global_transform.origin = last_ground_position
		await get_tree().create_timer(.7).timeout
		waveEffect.queue_free()


func LandingGroundEffect():
	if is_on_floor():
		if (is_in_air == true):
			is_in_air = false
			var waveEffect = waveEffect.instantiate()
			get_parent().add_child(waveEffect)
			waveEffect.global_transform.origin = last_ground_position
			await get_tree().create_timer(.7).timeout
			waveEffect.queue_free()
	else:
		is_in_air = true



func _proccess_sprinting(delta):
	if sprinting && is_moving && Stamina_bar.value > 0 && can_sprint && can_move == true:
		sprint_timer += delta
		is_sprinting = true
		Stamina_bar.value -= sprinting_deplete_rate * delta
		
		target_speed = MAX_SPEED
		ACCELERATION = DASH_ACCELERATION
		DECELERATION = DASH_DECELERATION
		target_blend_amount = 1.0
		current_blend_amount = lerp(current_blend_amount, target_blend_amount, blend_lerp_speed * delta)
		
		if sprint_timer >= 0.2:
			$AnimationTree.set("parameters/Ground_Blend/blend_amount", 1)
		
		if sprint_timer >= 2:
			DASH_ACCELERATION = SECOND_DASH_ACCELERATION
			DASH_DECELERATION = SECOND_DASH_DECELERATION
			target_speed = SECOND_MAX_SPEED
			$AnimationTree.set("parameters/Ground_Blend2/blend_amount", 0)
		else:
			$AnimationTree.set("parameters/Ground_Blend2/blend_amount", -1)
		
		if Input.is_action_just_released("move_sprint") || sprint_timer >= 3 && jumping || jumping:
			is_sprinting = false
			target_speed = BASE_SPEED
			ACCELERATION = BASE_ACCELERATION
			DECELERATION = BASE_DECELERATION
			sprint_timer = 0.0
			$AnimationTree.set("parameters/Jump_Blend/blend_amount", 1)
			GroundSParkEffect()
		


	
		if Stamina_bar.value <= 0:
			is_sprinting = false
			can_sprint = false
			sprinting_refill_rate = sprinting_refill_rate_zero
			sprint_timer = 0.0
			
#			if sprinting:
#				print("YOU CANNOT SPRINT")
#				is_sprinting = false
#				sprinting_deplete_rate = 0
#				$AnimationTree.set("parameters/Ground_Blend2/blend_amount", -1)
#
			
			if Stamina_bar.value >= 0:
				if is_moving:
					current_speed = STAMINA_DEPLETED_SPEED
		else:
			sprinting_refill_rate = sprinting_refill_rate
			
			
	else:
		is_sprinting = false
		target_speed = BASE_SPEED
		ACCELERATION = BASE_ACCELERATION
		DECELERATION = BASE_DECELERATION
		$AnimationTree.set("parameters/Ground_Blend2/blend_amount", -1)
		
		if Stamina_bar.value < stamina:
			Stamina_bar.value += sprinting_refill_rate * delta
			
		if Stamina_bar.value == stamina:
			can_sprint = true

func _proccess_dodge(delta):
	if dodging && is_on_floor() && can_dodge && Stamina_bar.value > 0 && is_moving:
		is_dodging = true
		$AudioStreamPlayer2.play()
		last_ground_position = global_transform.origin 
		current_speed = DODGE_SPEED
		ACCELERATION = DODGE_ACCELERATION
		DECELERATION = DODGE_DECELERATION
		LERP_VAL = DODGE_LERP_VAL
		Stamina_bar.value -= 10
		print("DRAHON BALLLLL")
		$AnimationTree.set("parameters/Ground_Blend3/blend_amount", 0)
		
		dodge_cooldown_timer = dodge_cooldown  
		can_dodge = false  # Disable dodging until cooldown finishes
		
		AirWaveEffect()
		GroundSParkEffect()
		
		if Stamina_bar.value <= 0 && is_dodging:
			$AnimationTree.set("parameters/Ground_Blend3/blend_amount", 1)
			current_speed = BASE_SPEED
			print("UNABLE TO DODGE")
	if is_dodging:
		dodge_cooldown_timer -= delta
		
		if dodge_cooldown_timer <= 0:
			is_dodging = false
			print("wpooooooooooo")
			LERP_VAL = .2
			$AnimationTree.set("parameters/Ground_Blend3/blend_amount", -1)

func _proccess_cooldown(delta):
	if !can_dodge:
		dodge_cooldown_timer -= delta
		if dodge_cooldown_timer <= 0:
			can_dodge = true
			dodge_cooldown_timer = 0

	if Input.is_action_just_released("move_dodge"):
		$AnimationTree.set("parameters/Ground_Blend3/blend_amount", -1)
		ACCELERATION = BASE_ACCELERATION
		DECELERATION = BASE_DECELERATION
		if can_dodge:
			dodge_cooldown_timer = dodge_cooldown
			can_dodge = false

func _proccess_jump(delta):
	if !is_on_floor():
		air_timer += delta
		can_jump = false
		velocity.y -= custom_gravity * delta
	elif is_on_floor():
		can_jump = true
		$AnimationTree.set("parameters/Jump_Blend/blend_amount", -1)
		jump_counter = 0  # Reset jump counter when landing on the ground
		last_ground_position = global_transform.origin 

	if velocity.y > 0 && jump_timer >= 0.01:
		$AnimationTree.set("parameters/Jump_Blend/blend_amount", 1)

	if Input.is_action_pressed("move_jump") && jump_counter <= 0:
		jump_timer += delta
		air_timer += delta
		$AudioStreamPlayer3.play()

		if jump_timer <= 0.5:
			velocity.y = JUMP_VELOCITY
			can_jump = false
			jump_counter += 1  # Increase jump counter when jumping
			
			GeneralwaveEffect()

		else:
			velocity.y -= custom_gravity * delta
			$AnimationTree.set("parameters/Jump_Blend/blend_amount", 0)
			can_jump = false

	if !is_on_floor() && jump_timer >= 0.4:
		jump_timer = 0.4
		can_jump = false

	if Input.is_action_just_pressed("move_jump"):
		air_timer = 0.0
		jump_timer = 0.0

	if Input.is_action_just_released("move_jump"):
		air_timer = 0.0
		jump_timer = 0.0
		$AnimationTree.set("parameters/Jump_Blend/blend_amount", 0)

func _process_walljump(delta):
	if is_on_wall():
		if Input.is_action_just_pressed("move_jump"):
			var wall_normal = get_wall_normal()
			if wall_normal != null && wall_normal != Vector3.ZERO:
				wall_normal = wall_normal.normalized() 
				velocity = wall_normal * (JUMP_VELOCITY * WALL_JUMP_VELOCITY_MULTIPLIER)
				velocity.y += WALL_JUMP_VELOCITY_MULTIPLIER

				has_wall_jumped = true
				can_wall_jump = false
				wall_jump_position = global_transform.origin
				if has_wall_jumped:
					for node in wall_wave:
							node.global_transform.origin = wall_jump_position
							if node.has_node("AnimationPlayer"):
								node.get_node("AnimationPlayer").play("Landing_strong_001|CircleAction_002")


func _proccess_attack(delta):
	if is_attacking:
		attack_cooldown -= delta
	if attack_cooldown <= 0.0:
		is_attacking = false
	if Input.is_action_just_pressed("attack_light_1") && attack_cooldown <= 0.0 && is_on_floor() && can_attack:
		$AnimationTree.set("parameters/Attack_Shot/request", 1)
		current_speed = 0
		Attack_Box.monitoring = true
		is_attacking = true
		

		attack_cooldown = 0.5 # Set the cooldown time (0.5 seconds in this case)
		await get_tree().create_timer(0.2).timeout
		$AnimationTree.set("parameters/Attack_Shot/request", 2)
		
	else:
		Attack_Box.monitoring = false
		
	if Input.is_action_just_released("attack_light_1") && is_on_floor():
		attacklight1_timer = 0.0
		attacklight2_timer += delta
		Attack_Box.monitoring = false
		$AnimationTree.set("parameters/Attack_Shot/request", 2)
	
	#if Input.is_action_just_pressed("attack_light_1") && attacklight2_timer >= 0 && is_on_floor():
		#attacklight1_timer = 0.0
		#attacklight2_timer = 0.0
		#print("SECOND LIGHT ATTACK")
##		$AnimationTree.set("parameters/Attack_Shot2/request", 2)

			
func _physics_process(delta):
	_proccess_movement(delta)
	_proccess_jump(delta)
	_unhandled_input(delta)
	_proccess_dodge(delta)
	_proccess_cooldown(delta)
	_proccess_sprinting(delta)
	_proccess_attack(delta)
	LandingGroundEffect()
	
	playerHealthMan.health = playerHealthMan.max_health
	$player_health_label.value = playerHealthMan.health
	$player_health_label.max_value = playerHealthMan.max_health
	
	#if Attack_Box.monitoring == true:
		#print(Attack_Box.monitoring)
	
	if Input.is_action_just_pressed("mouse_left"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	sprinting = Input.is_action_pressed("move_sprint")
	dodging = Input.is_action_just_pressed("move_dodge")
	jumping = Input.is_action_pressed("move_jump")
	
	if is_on_floor():
		if sprinting && jumping:
			velocity.y = JUMP_VELOCITY * RUNJUMP_MULTIPLIER
	
	
	
	

	move_and_slide()


func _on_refill_cooldown_timeout():
	pass # Replace with function body.


#Attacking objects and enemies
func _on_attack_box_area_entered(area):
	if area.has_method("takeDamageEnemy") && !attack_proccessing && can_attack:
		enemyHealthMan.takeDamageEnemy(enemyHealthMan.health , attack_power)
		$AudioStreamPlayer.play()
		gameJuice.hitStop(0.15, area)
		attack_cooldown = 0.1
		
		Attack_Box.monitoring = false
		gameJuice.knockback(area.get_parent(), Attack_Box, 6)
		


func pause():
	process_mode = PROCESS_MODE_DISABLED

func unpause():
	process_mode = PROCESS_MODE_INHERIT

#things entering the players hurtbox
func _on_hurt_box_area_entered(area):
	if area.name == "enemyBox":
		if !is_on_floor():
			print("got hit in the air")
			$AnimationTree.set("parameters/Ground_Blend3/blend_amount", 1)
			can_move = false
			can_sprint = false
			can_attack = false
			
			await get_tree().create_timer(0.9).timeout
			$AnimationTree.set("parameters/Ground_Blend3/blend_amount", -1)
			can_move = true
			can_sprint = true
			can_attack = true
		
		elif is_on_floor():
			print("got hit in the floor")
			$AnimationTree.set("parameters/Ground_Blend3/blend_amount", 1)
			can_move = false
			await get_tree().create_timer(0.9).timeout
			can_move = true
			$AnimationTree.set("parameters/Ground_Blend3/blend_amount", -1)
			
		else:
			can_move = true
			$AnimationTree.set("parameters/Ground_Blend3/blend_amount", -1)
			
		
	pass # Replace with function body.
