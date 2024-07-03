extends ProgressBar
@onready var timer = $Timer
@onready var damage_bar = $DamageBar
var health = 0:set = _set_health

func _set_health(_value):
	var prev_health = health
	health = min(max_value,_value)
	value = health
	var percent  =  health / max_value *100
	if health > 40:
		get("theme_override_styles/fill").bg_color = Color.GREEN
	elif health > 15:
		get("theme_override_styles/fill").bg_color = Color.ORANGE
	else:
		get("theme_override_styles/fill").bg_color = Color.RED
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

func init_health_bar(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health


func _on_timer_timeout():
	damage_bar.value = health
