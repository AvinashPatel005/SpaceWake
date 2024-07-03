extends CharacterBody3D
var player =  null
@export var player_path : NodePath
const SPEED = 3.0
@onready var nav_agent = $NavigationAgent3D
@onready var animation_tree = $Node3D/Model/AnimationTree
@onready var fire = $Fire
@onready var player_ray = $RayCast3D
@onready var model = $Node3D
var bullet = load("res://scenes/bullet_enemy.tscn")
@onready var barrel = $Node3D/Model/Robot_Skeleton/Skeleton3D/GunBone/ShootFrom
@onready var eye = $Eye
@onready var body_collider = $CapsuleShape3D
@onready var ray_left = $RayCast3D/RayLeft
@onready var ray_right = $RayCast3D/RayRight
@onready var audio_stream_player_3d = $AudioStreamPlayer3D
@onready var walk = $Walk

var move_dir = 0
var move_period = 2
var instance
var is_alerted = false
var in_range = false
var is_escaped = false
var ready_to_fire = false
var dead = false
var can_move = true
var health = 0:set = _update_health
var walk_time_audio = 0.0
func _update_health(value):
	health += value
	if health>100.0:
		health = 100.0
	if health<0:
		health = 0.0
		dead = true
		fire.paused = true;
		

func _ready():
	player = get_node(player_path)
	_update_health(100)
	fire.start()
	fire.paused = true;

func _process(delta):
	velocity = Vector3.ZERO
	if not dead:	
		if player_ray.is_colliding():
			var collider = player_ray.get_collider()
			if collider.is_in_group("player"):
				in_range = true
			else:
				in_range = false
		else :
			in_range = false
		
		if is_alerted and not in_range and can_move:
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point-global_transform.origin).normalized()*SPEED
			eye.look_at(Vector3(next_nav_point.x,next_nav_point.y+1.8,next_nav_point.z),Vector3.UP)
			
		if global_position.distance_to(player.global_position)<1.5:
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = -(next_nav_point-global_transform.origin).normalized()*0.4*SPEED
			
		animation_tree.set("parameters/conditions/is_alert",is_alerted)
		animation_tree.set("parameters/conditions/is_away",!in_range&&is_alerted)
		animation_tree.set("parameters/conditions/in_range",in_range)
		animation_tree.set("parameters/conditions/is_escaped",is_escaped)
		if is_alerted:
			player_ray.look_at(Vector3(player.global_position.x,player.global_position.y+1.8,player.global_position.z),Vector3.UP)
			if can_move:
				if in_range:
					model.rotation.y =lerp_angle(model.rotation.y, player_ray.rotation.y ,delta*4)
				else:
					model.rotation.y =lerp_angle(model.rotation.y, eye.rotation.y ,delta*4)
		
		if in_range:
			fire.paused = false;
			if ray_left.is_colliding() and move_dir==move_period:
				move_dir = 0
			if ray_right.is_colliding() and move_dir==-move_period:
				move_dir = 0
			position += ray_left.global_transform.basis*Vector3(-SPEED*0.5,0,0)*delta*floor(move_dir/move_period)
		else:
			fire.paused = true;
			move_dir = 0
		animation_tree.set("parameters/conditions/move_stop",move_dir<move_period and move_dir>-move_period)
		animation_tree.set("parameters/conditions/move_left",move_dir==-move_period)
		animation_tree.set("parameters/conditions/move_right",move_dir==move_period)
		
	animation_tree.set("parameters/conditions/dead",dead)
	move_and_slide()
	


func _on_alert_range_body_entered(body):
	is_alerted = true

func _on_fire_timeout():
	if ready_to_fire:
		instance = bullet.instantiate()
		instance.position = barrel.global_position
		instance.transform.basis = player_ray.global_transform.basis
		get_node("/root/Game").add_child(instance)
		audio_stream_player_3d.play()
		var rng = RandomNumberGenerator.new()
		move_dir = rng.randi_range(-move_period,move_period)
		animation_tree.set("parameters/conditions/move_stop",move_dir<move_period and move_dir>-move_period)
		animation_tree.set("parameters/conditions/move_left",move_dir==-move_period)
		animation_tree.set("parameters/conditions/move_right",move_dir==move_period)
		
	

func _on_escape_range_body_exited(body):
	if is_alerted:
		is_escaped = true
	is_alerted = false
	in_range = false
	
	
func stay_alert():
	is_alerted = true

func _on_escape_range_body_entered(body):
	if is_escaped:
		is_alerted = true
		is_escaped = false



func _on_area_3d_part_hit(_damage):
	is_alerted = true
	_update_health(-_damage*8)

func _disable_move():
	can_move=false
	
func start_fire():
	ready_to_fire = true
	can_move = true	
	
func on_dead_callback():
	body_collider.disabled = true

func reinitialize():
	_update_health(100)
	fire.paused = false;
	dead = false
	body_collider.disabled = false
	is_alerted = true
	animation_tree.set("parameters/conditions/reinit",true)
	await get_tree().create_timer(0.6).timeout
	animation_tree.set("parameters/conditions/reinit",false)

func play_walk():
	if !walk.is_playing():
		walk.play()
