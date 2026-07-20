extends Node3D

@export var reveal_distance := 8.0
@export var fade_speed := 5.0
@export var min_scale := 0.8
@export var max_scale := 2.4

var player: Node3D
var start_position: Vector3
var float_offset := 0.0
var float_speed := 1.0
var float_height := 0.2

@onready var sprite: Sprite3D = $Sprite3D

func _ready():
	start_position = global_position

	# Zufällige Größe
	var random_scale = randf_range(min_scale, max_scale)
	scale = Vector3.ONE * random_scale

	# Zufällige Schwebephase
	float_offset = randf_range(0.0, TAU)
	float_speed = randf_range(0.5, 1.5)

func _process(delta):
	if player == null:
		return

	var target_alpha := 1.0

	if global_position.distance_to(player.global_position) < reveal_distance:
		target_alpha = 0.0

	sprite.modulate.a = move_toward(
		sprite.modulate.a,
		target_alpha,
		fade_speed * delta
	)
