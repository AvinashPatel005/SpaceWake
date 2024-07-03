extends CharacterBody3D
@onready var head = $Neck/Head
@onready var camera = $Neck/Head/Camera3D
@onready var normal_collider = $NormalCollider
@onready var sneak_collider = $SneakCollider
@onready var ray_cast = $RayCast3D
@onready var arm = $Neck/Head/Camera3D/Arm
@onready var hand = $Neck/Head/Camera3D/Arm/Hand
@onready var animation_player = $AnimationPlayer
@onready var health_bar = $Control/HealthBar
@onready var damage_effect = $CanvasLayer/DamageEffect
@onready var canvas_layer = $CanvasLayer
@onready var jump = $Jump
@onready var walk = $Walk
@onready var jump_start = $JumpStart
@onready var dead = $Control/Dead

const WALK_SPEED = 5.0
const REVERSE_WALK_SPEED = 3.0
const SPRINT_SPEED = 7.0
const SNEAK_SPEED = 2.0

var is_sneaking = false
const SNEAK_HEAD_SHIFT = -0.5

var speed = WALK_SPEED

const JUMP_VELOCITY = 6

const HORIZONTAL_SENSITIVITY = 0.3
const VERTICAL_SENSITIVITY = 0.3

var direction = Vector3.ZERO
const LERP_INERTIA = 10
const JUMP_AIR_CONTROL = 3

const FOV_BASE = 75.0
const FOV_CHANGE = 5

const BOB_AMP = 0.06
const BOB_FREQ = 2
var t_bob = 0.0

const ARM_SWAY_AMP = 0.005
const ARM_SWAY_FREQ = 2
var arm_sway_multiplier = 1.0
var t_arm_sway = 0.0

const ADS_FOV = 35.0
var in_ads = false
var ADS_MOUSE_SENS_MULTI = 0.3
var default_hand_pos
var ads_hand_pos = Vector3(0,-0.15,-0.15)

var is_player_ready = false

var health = 0:set = _update_health
var jump_queued = false
func _update_health(value):
	health += value
	damage_effect.visible = health<=15
	if health>100.0:
		health = 100.0
	if health<0:
		health = 0.0
		dead.visible = true
		await get_tree().create_timer(0.6).timeout
		
	health_bar._set_health(health)
	if health<=0:
		dead.visible = true
		await get_tree().create_timer(0.6).timeout
		get_tree().reload_current_scene()
	
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 14

var has_relic = false

var walk_time_audio = 0.0

func _ready():
	_update_health(100)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_hand_pos = hand.transform.origin
func _input(event):
	if event is InputEventMouseMotion and is_player_ready:
		if in_ads:
			head.rotate_y(deg_to_rad(-event.relative.x*HORIZONTAL_SENSITIVITY*ADS_MOUSE_SENS_MULTI))
			camera.rotate_x(deg_to_rad(-event.relative.y*VERTICAL_SENSITIVITY*ADS_MOUSE_SENS_MULTI))
			camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-70),deg_to_rad(80))
		else:
			head.rotate_y(deg_to_rad(-event.relative.x*HORIZONTAL_SENSITIVITY))
			camera.rotate_x(deg_to_rad(-event.relative.y*VERTICAL_SENSITIVITY))
			camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-70),deg_to_rad(80))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		jump_queued = true
		velocity.y -= gravity * delta
	else:
		if jump_queued:
			jump.play()
			jump_queued = false

	if is_player_ready:
		# Handle jump.
		if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_queued = true
			jump_start.play()
		
		# Sprint and sneak logic
		if Input.is_action_pressed("sneak"):
			speed = SNEAK_SPEED
			is_sneaking = true
		else :
			is_sneaking = false
			if Input.is_action_pressed("sprint"):
				speed = SPRINT_SPEED
			else:
				speed = WALK_SPEED
			if Input.is_action_pressed("down"):
				speed = REVERSE_WALK_SPEED
		
		if is_sneaking:
			head.position.y = lerp(head.position.y,SNEAK_HEAD_SHIFT,delta*LERP_INERTIA)
			normal_collider.disabled = true
			sneak_collider.disabled = false
		else:
			if ray_cast.is_colliding():
				speed=SNEAK_SPEED
			else:
				head.position.y = lerp(head.position.y,0.0,delta*LERP_INERTIA)
				normal_collider.disabled = false
				sneak_collider.disabled = true
		
		if hand.get_child_count():
			#ads
			if Input.is_action_pressed("ads") and hand.get_child(0) is Gun:
				in_ads = true
				arm_sway_multiplier = 0.2
				speed=SNEAK_SPEED
				camera.fov = lerp(camera.fov,ADS_FOV,delta*LERP_INERTIA)
				hand.transform.origin = lerp(hand.transform.origin,ads_hand_pos,delta*LERP_INERTIA)
			else:
				in_ads = false
				arm_sway_multiplier = 1
				camera.fov = lerp(camera.fov,FOV_BASE,delta*LERP_INERTIA)
				hand.transform.origin = lerp(hand.transform.origin,default_hand_pos,delta*LERP_INERTIA)
			
			#hand interaction
			if Input.is_action_pressed("fire"):
				hand.get_child(0).interact()
			
		#movement input
		var input_dir = Input.get_vector("left", "right", "up", "down")
		direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		#fov change
		if not in_ads:
			if direction:
				var speed_change = speed-WALK_SPEED
				var fov_change
				if speed_change>0:
					fov_change = FOV_BASE+FOV_CHANGE*(speed-WALK_SPEED)
				else:
					fov_change = FOV_BASE
				camera.fov = lerp(camera.fov,fov_change,delta*LERP_INERTIA)
			else:
				camera.fov = lerp(camera.fov,FOV_BASE,delta*LERP_INERTIA)
		
		
		#handle bob
		t_bob += velocity.length()*delta*float(is_on_floor())
		camera.transform.origin = lerp(camera.transform.origin,handle_bob(t_arm_sway),delta*LERP_INERTIA)
		
		#handle arm sway
		t_arm_sway += velocity.length()*delta*float(is_on_floor())
		arm.transform.origin = lerp(arm.transform.origin,handle_sway(t_arm_sway),delta*LERP_INERTIA)
		#movement handle
		if is_on_floor():
			if direction:
				walk_time_audio+=delta
				if !walk.is_playing() &&walk_time_audio>2/velocity.length():
					walk_time_audio = 0.0
					walk.play()
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = lerp(velocity.x,0.0,delta*LERP_INERTIA)
				velocity.z = lerp(velocity.z,0.0,delta*LERP_INERTIA)
		else:
			velocity.x = lerp(velocity.x,direction.x * speed,delta*JUMP_AIR_CONTROL)
			velocity.z = lerp(velocity.z,direction.z * speed,delta*JUMP_AIR_CONTROL)
	else: 
		velocity.x = lerp(velocity.x,0.0,delta*JUMP_AIR_CONTROL)
		velocity.z = lerp(velocity.z,0.0,delta*JUMP_AIR_CONTROL)
	move_and_slide()

func handle_bob(t_bob):
	var pos = Vector3.ZERO
	if !direction:
		return pos
	pos.y = sin(t_bob*BOB_FREQ)*BOB_AMP
	pos.x = cos(t_bob*BOB_FREQ/2)*BOB_AMP
	return pos
func handle_sway(t_arm_sway):
	var pos = Vector3.ZERO
	if !direction:
		return pos
	pos.y = sin(-t_arm_sway*ARM_SWAY_FREQ)*ARM_SWAY_AMP*arm_sway_multiplier
	pos.x = cos(-t_arm_sway*ARM_SWAY_FREQ/2)*ARM_SWAY_AMP*arm_sway_multiplier
	return pos
func player_ready():
	is_player_ready = true

func take_obj(obj):
	var object = load(obj).instantiate()
	hand.add_child(object)


func _on_damage(value):
	_update_health(-value)

func hit():
	_update_health(-5)

func _on_heal(value):
	_update_health(value)



func _on_computer_system_command_to_player(flag):
	if flag:
		is_player_ready = false
	else:
		is_player_ready = true


func _on_table_relic_give_relic():
	has_relic = true
