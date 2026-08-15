extends Node

@export var destroy_when_nolamp = true
@export var hp = 2

@onready var mesh: MeshInstance3D = $Lamp

func _ready() -> void:
	mesh.material_override = mesh.get_active_material(0).duplicate()

func _process(delta: float) -> void:
	if hp <= 1:
		var material := mesh.material_override as StandardMaterial3D
	
		if material:
			material.albedo_color = Color.RED
	if hp <= 0:
		if destroy_when_nolamp:
			get_parent().queue_free()
		else:
			queue_free()
