extends Interactable
@export var interact_name:String = "Button"
@export var interact_text:String = "Heal"
@onready var range = $Range
@export var is_active = true
@export var heal_amount = 50.0
@onready var timer = $Timer
@onready var active = $Active
@onready var audio_stream_player_3d = $AudioStreamPlayer3D

var healing_left;
var healing = false
signal heal
func interact():
	if is_active:
		healing = true
		healing_left = heal_amount
		audio_stream_player_3d.play()
		interact_text = "Reinitializing"
		is_active = false
		timer.start()

func _process(delta):
	active.visible = is_active
	if healing and healing_left>=0:
		heal.emit(50*delta)
		healing_left -= 50*delta
	else:
		healing = false
		
func _on_timer_timeout():
	is_active = true
	interact_text = "Heal"


func _on_range_body_exited(body):
	healing=false
