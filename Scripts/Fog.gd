extends Node3D

@export var reveal_distance := 8.0
@export var max_reveal_distance := 12.0 # Helligkeit 0
@export var min_reveal_distance := 3.0  # Dunkelheit 100
@export var fade_speed := 5.0
@export var min_scale := 1.4
@export var max_scale := 2.4

var player: Node3D
var start_position: Vector3
var float_offset := 0.0
var float_speed := 1.0
var float_height := 0.2
var sight_areas: Array[Area3D] = []

@onready var sprite: Sprite3D = $Sprite3D

func _ready():
	start_position = global_position

	# Zufällige Größe
	var random_scale = randf_range(min_scale, max_scale)
	scale = Vector3.ONE * random_scale

	# Zufällige Schwebephase
	float_offset = randf_range(0.0, TAU)
	float_speed = randf_range(0.5, 1.5)
	
	#Random Color
	var base_color = Color(0.227, 0.0, 0.565, 1.0)

	var variation := 0.15
	var random_color = Color(
		clamp(base_color.r + randf_range(-variation, variation), 0.0, 1.0),
		clamp(base_color.g + randf_range(-variation, variation), 0.0, 1.0),
		clamp(base_color.b + randf_range(-variation, variation), 0.0, 1.0),
		1.0
	)

	sprite.modulate = random_color

func _process(delta: float) -> void:
	var target_alpha := 1.0

	#Invisible around Player
	if player != null:
		if global_position.distance_to(player.global_position) < get_reveal_distance():
			target_alpha = 0.0

	var query := PhysicsPointQueryParameters3D.new()
	query.position = global_position
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var hits := get_world_3d().direct_space_state.intersect_point(query)

	for hit in hits:
		var area := hit["collider"] as Area3D

		if area != null and area.is_in_group("enemy_sight_areas"):
			target_alpha = 0.0
			break

	sprite.modulate.a = move_toward(
		sprite.modulate.a,
		target_alpha,
		fade_speed * delta
	)

func get_reveal_distance() -> float:
	var darkness: float = clampf(float(Globals.darkness_level), 0.0, 100.0) / 100.0
	return lerpf(max_reveal_distance, min_reveal_distance, darkness)
