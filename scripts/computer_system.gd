extends Interactable
@export var interact_name:String = "System"
@export var interact_text:String = "Interact"
@export var lock_doors:Array[Node3D]
@export var alarm:AudioStreamPlayer3D
var puzzle = load("res://scenes/puzzle.tscn")
signal command_to_player(flag)
var is_active = true
var is_locked = false
@onready var completed_tune = $Completed
@onready var failed = $Failed

func interact():
	if is_active and is_locked:
		add_child(puzzle.instantiate())
		command_to_player.emit(1)

func _process(delta):
	if is_active and is_locked:
		interact_text = "BruteFore"
		lock_system()
	else:
		interact_text = ""

func lock_system():
	is_locked = true
	for obj in lock_doors:
		if obj.get_status():
			obj.close()
		obj.locked = true
		
func unlock_system():
	is_locked = false
	for obj in lock_doors:
		obj.locked = false

func completed():
	unlock_system()
	alarm.stop()
	is_active = false
	is_locked = false
	get_tree().call_group("reinitialize_enemy","reinitialize")
	get_tree().call_group("lights","turn_to_white")
	completed_tune.play()
	command_to_player.emit(0)

func aborted():
	failed.play()
	command_to_player.emit(0)


func _on_cut_scene_trigger_lock_system():
	is_locked=true
