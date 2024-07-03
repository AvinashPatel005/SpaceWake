extends Node3D
@export var alarm:AudioStreamPlayer3D

@export var is_active = true
signal lock_system
func _on_body_entered(body):
	if body.is_in_group("player") and is_active:
		lock_system.emit()
		alarm.play()
		is_active = false
		get_tree().call_group("reinitialize_enemy","stay_alert")
		get_tree().call_group("lights","turn_to_red")
