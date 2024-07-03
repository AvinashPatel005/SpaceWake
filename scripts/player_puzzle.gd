extends CharacterBody2D
@onready var up_ray = $UpRay
@onready var down_ray = $DownRay
@onready var left_ray = $LeftRay
@onready var right_ray = $RightRay
@onready var animated_sprite_2d = $AnimatedSprite2D


const SPEED = 5.0
var input = Vector2.ZERO
var last_ray
func _ready():
	last_ray = down_ray
func _physics_process(delta):
	if last_ray.is_colliding():
		if Input.is_action_just_pressed("up"):
			input = Vector2.UP
			last_ray = up_ray
		elif Input.is_action_just_pressed("down"):
			input = Vector2.DOWN
			last_ray = down_ray
		elif Input.is_action_just_pressed("left"):
			input = Vector2.LEFT
			animated_sprite_2d.flip_h=true
			last_ray = left_ray
		elif Input.is_action_just_pressed("right"):
			input = Vector2.RIGHT
			animated_sprite_2d.flip_h=false
			last_ray = right_ray
	
	
	
	if !last_ray.is_colliding():
		animated_sprite_2d.play("default")
		position += input * SPEED
	else:
		animated_sprite_2d.stop()

