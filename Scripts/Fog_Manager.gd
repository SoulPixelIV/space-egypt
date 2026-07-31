extends Node3D

@export var fog_scene: PackedScene
@export var player: Node3D

@export var size := 12
@export var spacing := 1

var sight_areas: Array[Area3D] = []

func _ready():
	find_enemy_sight_areas()
	
	for x in range(-size, size):
		for z in range(-size, size):

			var fog = fog_scene.instantiate()
			add_child(fog)

			var offset = Vector3(
			randf_range(-1.5, 1.5),
			0,
			randf_range(-1.5, 1.5)
			)

			var fog_height = randf_range(-10.0, 10.0)

			fog.global_position = Vector3(
				x * spacing + randf_range(-1.5,1.5),
				fog_height,
				z * spacing + randf_range(-1.5,1.5)
			)

			fog.player = player
			fog.sight_areas = sight_areas
			
func _process(_delta: float) -> void:
	if player == null:
		return

	#Fog follows Player
	global_position.x = player.global_position.x
	global_position.z = player.global_position.z
	
func find_enemy_sight_areas() -> void:
	sight_areas.clear()

	for enemy in get_tree().get_nodes_in_group("enemy"):
		var area := enemy.get_node_or_null("AreaOfSight") as Area3D

		if area != null:
			sight_areas.append(area)
