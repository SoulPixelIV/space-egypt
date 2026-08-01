extends CharacterBody3D

enum State {
	PATROL,
	CHASE
}

const SPEED := 3.5
const ARRIVAL_DISTANCE := 1.0

@export var player: CharacterBody3D

@onready var patrol_points = $"../PatrolPoints".get_children()
@onready var spotlight: Area3D = $Spotlight

@onready var area_of_sight: Area3D = $AreaOfSight
@onready var line_of_sight: MeshInstance3D = $AreaOfSight/LineOfSight
@onready var sight_collision: CollisionShape3D = $AreaOfSight/CollisionShape3D

@onready var visible_area: Area3D = $VisibleArea
@onready var visible_collision: CollisionShape3D = $VisibleArea/CollisionShape3D

var current_point := 0
var state = State.PATROL

func _ready() -> void:
	# Damit Fog ausschließlich diese Areas als Sichtbereiche erkennt.
	area_of_sight.add_to_group("enemy_sight_areas")
	visible_area.add_to_group("enemy_sight_areas")

	# Erstellt eine passende CollisionShape aus deinem Sichtkegel-Mesh.
	sight_collision.shape = line_of_sight.mesh.create_convex_shape()

	# Wichtig, falls dein Mesh gedreht oder verschoben wurde.
	sight_collision.transform = line_of_sight.transform
	
	spotlight.tree_exited.connect(_on_spotlight_destroyed)

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Zum Testen State wechseln
	if Input.is_action_just_pressed("toggle_state"):
		if state == State.PATROL:
			state = State.CHASE
			print("CHASE")
		else:
			state = State.PATROL
			print("PATROL")

	match state:
		State.PATROL:
			patrol(delta)

		State.CHASE:
			chase(delta)

	move_and_slide()

func patrol(delta):
	if patrol_points.is_empty():
		return

	var target = patrol_points[current_point].global_position

	move_to_position(target, delta)

	if global_position.distance_to(target) <= ARRIVAL_DISTANCE:
		current_point = (current_point + 1) % patrol_points.size()

func chase(delta):
	if player == null:
		return

	move_to_position(player.global_position, delta)

func move_to_position(target: Vector3, delta):
	var direction = target - global_position
	direction.y = 0

	if direction.length() < 0.01:
		velocity.x = 0
		velocity.z = 0
		return

	direction = direction.normalized()

	var target_angle = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, 8.0 * delta)

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

#Area of Sight
func _on_area_of_sight_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
		state = State.CHASE
		print("PLAYER COLLISION")

func _on_area_of_sight_body_exited(body: Node3D) -> void:
	#player = null
	#state = State.PATROL
	print("PLAYER EXIT")

func _on_spotlight_destroyed() -> void:
	queue_free()
