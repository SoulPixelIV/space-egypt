extends CharacterBody3D

enum State {
	IDLE,
	PATROL,
	CHASE,
	STUCK
}

const ARRIVAL_DISTANCE := 1.0

@export var speed := 2.5

@onready var patrol_points = %PatrolPoints.get_children()

@onready var spotlight: Area3D = $Spotlight
@onready var state_text: Label3D = $EnemyStateText

@onready var area_of_sight: Area3D = $AreaOfSight
@onready var line_of_sight: MeshInstance3D = $AreaOfSight/LineOfSight
@onready var sight_collision: CollisionShape3D = $AreaOfSight/CollisionShape3D

@onready var visible_area: Area3D = $VisibleArea
@onready var visible_collision: CollisionShape3D = $VisibleArea/CollisionShape3D

var current_point := 0
var state := State.PATROL
var current_state := ""


func _ready() -> void:
	# Beide Bereiche können Fog entfernen.
	area_of_sight.add_to_group("enemy_sight_areas")
	visible_area.add_to_group("enemy_sight_areas")

	# CollisionShape des Sichtkegels aus dem Cone-Mesh erzeugen.
	sight_collision.shape = line_of_sight.mesh.create_convex_shape()
	sight_collision.transform = line_of_sight.transform

	spotlight.tree_exited.connect(_on_spotlight_destroyed)


func _physics_process(delta: float) -> void:
	# Schwerkraft
	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		State.PATROL:
			patrol(delta)
			current_state = "Patrolling"

		State.IDLE:
			idle()
			current_state = "Idling"

		State.STUCK:
			stuck()
			current_state = "Stuck"

	move_and_slide()

	# Anhalten, falls die Lampe den EnemyHolder trifft.
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var hit_body := collision.get_collider() as Node3D

		if hit_body and hit_body.is_in_group("enemy_holder"):
			state = State.STUCK
			print("Lampe steckt fest.")

	state_text.text = current_state


func patrol(delta: float) -> void:
	if patrol_points.is_empty():
		return

	var target: Vector3 = patrol_points[current_point].global_position
	move_to_position(target, delta)

	if global_position.distance_to(target) <= ARRIVAL_DISTANCE:
		current_point = (current_point + 1) % patrol_points.size()


func idle() -> void:
	velocity.x = 0
	velocity.z = 0


func stuck() -> void:
	velocity.x = 0
	velocity.z = 0


func move_to_position(target: Vector3, delta: float) -> void:
	var direction := target - global_position
	direction.y = 0

	if direction.length() < 0.01:
		velocity.x = 0
		velocity.z = 0
		return

	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed


func _on_collision_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy_holder"):
		state = State.STUCK
		print("Lampe hat EnemyHolder getroffen.")


func _on_spotlight_destroyed() -> void:
	var tree := get_tree()

	if tree:
		tree.call_group("ui_control", "show_enemy_defeated")

	queue_free()
