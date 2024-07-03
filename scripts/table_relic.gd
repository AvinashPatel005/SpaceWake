extends Interactable
@export var interact_name:String = "RelicTable"
@export var interact_text:String = "Pick"
@export var has_relic = true
@onready var active = $Active
@onready var ship = $"table-display/ship"
@onready var audio_stream_player_3d = $AudioStreamPlayer3D

signal give_relic
func interact():
	if has_relic:
		give_relic.emit()
		ship.visible = false
		has_relic = false
		audio_stream_player_3d.play()
		interact_text = ""

func _process(delta):
	active.visible = has_relic
