extends Node3D

@export var fog_scene: PackedScene
@export var player: Node3D

@export var size := 20
@export var spacing := 3.0

func _ready():
	for x in range(-size, size):
		for z in range(-size, size):

			var fog = fog_scene.instantiate()
			add_child(fog)

			var offset = Vector3(
			randf_range(-1.5, 1.5),
			0,
			randf_range(-1.5, 1.5)
			)

			var fog_height = randf_range(1.5, 5.0)

			fog.global_position = Vector3(
				x * spacing + randf_range(-1.5,1.5),
				fog_height,
				z * spacing + randf_range(-1.5,1.5)
			)

			fog.player = player
