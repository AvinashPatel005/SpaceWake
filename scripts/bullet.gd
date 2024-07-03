extends Node3D
const SPEED = 40.0
@onready var mesh_instance_3d = $MeshInstance3D
@onready var ray_cast_3d = $RayCast3D
@onready var gpu_particles_3d = $GPUParticles3D
@onready var hit = $AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ray_cast_3d.is_colliding():
		mesh_instance_3d.visible = false
		gpu_particles_3d.emitting  = true
		ray_cast_3d.enabled = false
		if ray_cast_3d.get_collider().is_in_group("enemy") :
			hit.play()
		if ray_cast_3d.get_collider().is_in_group("enemy") or ray_cast_3d.get_collider().is_in_group("player"):
			ray_cast_3d.get_collider().hit()	
		await get_tree().create_timer(3.0).timeout
		queue_free()
	else:
		position += transform.basis*Vector3(0,0,-SPEED)*delta

func _on_delete_timeout():
	queue_free()
