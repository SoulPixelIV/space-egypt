extends Node3D

@export var speed := 30.0
var direction := Vector3.ZERO

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("destructible"):
		area.queue_free()

	if area.is_in_group("solid"):
		queue_free()
