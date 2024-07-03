extends Gun
@onready var animation_player = $AnimationPlayer
@onready var barrel = $RayCast3D
var bullet = load("res://scenes/bullet.tscn")
var instance

func interact():
	if not animation_player.is_playing():
		animation_player.play("shoot")
		instance = bullet.instantiate()
		instance.position = barrel.global_position
		instance.transform.basis = barrel.global_transform.basis
		get_node("/root/Game").add_child(instance)
		
