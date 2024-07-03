extends Node3D
@onready var animation_player = $AnimationPlayer
@export var opened = false
@export var locked = false

func _ready():
	if opened:
		animation_player.play("open")

func get_status():
	return opened
func is_locked():
	return locked
func communicate():
	if !animation_player.is_playing():
		if opened:
			animation_player.play("close")
			opened=false
		else:
			animation_player.play("open")
			opened=true

func close():
	animation_player.play("close")
	opened=false
