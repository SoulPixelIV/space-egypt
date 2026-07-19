extends Node3D

@export var speed := 30.0
var direction := Vector3.ZERO

func _physics_process(delta):
	global_position += direction * speed * delta
