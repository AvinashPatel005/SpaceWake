extends Interactable
@export var interact_name:String = "GunTable"
@export var interact_text:String = "Equip"
@export var has_gun = true
@export var gun = "res://scenes/pistol.tscn"
@onready var active = $Active
@onready var audio_stream_player_3d = $AudioStreamPlayer3D

@onready var holder = $Holder
var instance
signal give_to_player
func _ready():
	var gun_obj = load(gun)
	instance = gun_obj.instantiate()
	holder.add_child(instance)
	
func _process(delta):
	active.visible = has_gun
func interact():
	if has_gun:
		give_to_player.emit(gun)
		audio_stream_player_3d.play()
		holder.remove_child(instance)
		has_gun=false
		interact_text=""
