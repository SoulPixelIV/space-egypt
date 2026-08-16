extends Node

@export var destroy_when_nolamp = true
@export var hp = 2

@onready var mesh: MeshInstance3D = $Lamp
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	mesh.material_override = mesh.get_active_material(0).duplicate()

func _process(delta: float) -> void:
	if hp <= 1:
		var material := mesh.material_override as StandardMaterial3D
	
		if material:
			material.albedo_color = Color.RED
			
		if get_parent().state != get_parent().State.STUCK:
			get_parent().state = get_parent().State.CHASE
			get_parent().player = player
	if hp <= 0:
		if destroy_when_nolamp:
			get_parent()._on_spotlight_destroyed()
		else:
			queue_free()
			
func play_sound():
	$AudioStreamPlayer3D.play()
