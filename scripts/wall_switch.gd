extends Interactable
@export var interact_name:String = "Button"
@export var interact_text:String = "Interact"
@export var is_active = true
@export var target:Node3D

@onready var disabled = $Disabled
@onready var enabled = $Enabled
@onready var closed = $Closed

func _process(delta):
	var locked=target.is_locked()
	is_active=!locked 
	var status=target.get_status()
	if is_active:
		if status:
			disabled.visible = false
			enabled.visible = true
			closed.visible = false
			interact_text="Close"
		else:
			disabled.visible = false
			enabled.visible = false
			closed.visible = true
			interact_text="Open"
	else:
		disable_visual()
		interact_text="Access Denied"

func disable_visual():
	disabled.visible = true
	enabled.visible = false
	closed.visible = false
	
func interact():
	if is_active:
		target.communicate()
	
	
