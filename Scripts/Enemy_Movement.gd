extends CharacterBody3D

enum State {
	IDLE,
	PATROL,
	CHASE,
	STUCK
}

const ARRIVAL_DISTANCE := 1.0

@export var player: CharacterBody3D
@export var speed := 2.5
@onready var damage_timer: Timer = $DamageTime
var damage_target: CharacterBody3D = null

@onready var patrol_points = %PatrolPoints.get_children()
@onready var spotlight: Area3D = $Spotlight
@onready var state_text: Label3D = $EnemyStateText

@onready var area_of_sight: Area3D = $AreaOfSight
@onready var line_of_sight: MeshInstance3D = $AreaOfSight/LineOfSight
@onready var sight_collision: CollisionShape3D = $AreaOfSight/CollisionShape3D

@onready var visible_area: Area3D = $VisibleArea
@onready var visible_collision: CollisionShape3D = $VisibleArea/CollisionShape3D

var current_point := 0
var state = State.IDLE
var current_state = ""

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
			current_state = "Patrolling"

		State.CHASE:
			chase(delta)
			current_state = State.CHASE
			current_state = "Chasing"
			
		State.IDLE:
			idle(delta)
			current_state = "Idling"
			
		State.STUCK:
			stuck()
			current_state = "Stuck"

	move_and_slide()
	
	#Check for Collision with Enemy Holder
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var hit_body := collision.get_collider() as Node3D

		if hit_body and hit_body.is_in_group("enemy_holder"):
			state = State.STUCK
			print("YES - enemy stuck")
	
	state_text.text = current_state

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

func idle(delta):
	velocity.x = 0
	velocity.z = 0

func stuck() -> void:
	velocity.x = 0
	velocity.z = 0

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

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

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

func _on_collision_zone_body_entered(body: Node3D) -> void:
	#if body.is_in_group("enemy_holder"):
	state = State.STUCK
	print("YES")

func _on_spotlight_destroyed() -> void:
	var tree := get_tree()
	if tree:
		get_tree().call_group("ui_control", "show_enemy_defeated")
	queue_free()

func _on_damage_field_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		damage_target = body
		damage_timer.start()
		print("PLAYER IN DAMAGE FIELD")

func _on_damage_field_body_exited(body: Node3D) -> void:
	if body == damage_target:
		damage_target = null
		damage_timer.stop()
		print("PLAYER LEFT DAMAGE FIELD")

func _on_damage_time_timeout() -> void:
	if is_instance_valid(damage_target):
		damage_target.hp -= 1
		print("Player HP:", damage_target.hp)
	else:
		damage_timer.stop()
