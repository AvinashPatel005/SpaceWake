extends Interactable
@export var interact_name:String = "RelicTable"
@export var interact_text:String = "Place"
@export var has_relic = false
@onready var active = $Active
@onready var ship = $"table-display-small/ship"
@onready var place = $Place
@onready var teleport = $Teleport

func interact():
	if not has_relic:
		var player = get_tree().get_first_node_in_group("player")
		if player.has_relic:
			player.has_relic = false
			has_relic = true
			place.play()
			interact_text = ""
		else:
			interact_text = "Find the Relic and place here"
			await get_tree().create_timer(1).timeout
			interact_text = "Place"
	else:
		print("End")
		get_tree().change_scene_to_file("res://scenes/main_screen.tscn")
		teleport.play()
		
func _process(delta):
	active.visible = has_relic
	ship.visible = has_relic
	if has_relic:
		interact_text = "Teleport"
	else:
		interact_text = "Place"
