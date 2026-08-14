extends CharacterBody3D

enum State {
	IDLE,
	PATROL,
	CHASE,
	STUCK,
	WANDER
}

const ARRIVAL_DISTANCE := 1.0

@export var player: CharacterBody3D
@export var speed := 2.5
@export var remaining_spotlights := 2

@onready var patrol_points = %PatrolPoints.get_children()
@onready var spotlight: Area3D = $Spotlight
@onready var spotlight2: Area3D = $Spotlight2
@onready var state_text: Label3D = $EnemyStateText

@onready var area_of_sight: Area3D = $AreaOfSight
@onready var area_of_sight2: Area3D = $AreaOfSight2
@onready var line_of_sight: MeshInstance3D = $AreaOfSight/LineOfSight
@onready var line_of_sight2: MeshInstance3D = $AreaOfSight2/LineOfSight2
@onready var sight_collision: CollisionShape3D = $AreaOfSight/CollisionShape3D
@onready var sight_collision2: CollisionShape3D = $AreaOfSight2/CollisionShape3D2

@onready var visible_area: Area3D = $VisibleArea
@onready var visible_collision: CollisionShape3D = $VisibleArea/CollisionShape3D

var current_point := 0
var state = State.IDLE
var current_state = ""
var wander_direction := Vector3.ZERO

func _ready() -> void:
	# Damit Fog ausschließlich diese Areas als Sichtbereiche erkennt.
	area_of_sight.add_to_group("enemy_sight_areas")
	area_of_sight2.add_to_group("enemy_sight_areas")
	visible_area.add_to_group("enemy_sight_areas")

	# Erstellt eine passende CollisionShape aus deinem Sichtkegel-Mesh.
	sight_collision.shape = line_of_sight.mesh.create_convex_shape()
	sight_collision2.shape = line_of_sight2.mesh.create_convex_shape()

	# Wichtig, falls dein Mesh gedreht oder verschoben wurde.
	sight_collision.transform = line_of_sight.transform
	sight_collision2.transform = line_of_sight2.transform
	
	spotlight.tree_exited.connect(_on_spotlight_destroyed)
	spotlight2.tree_exited.connect(_on_spotlight2_destroyed)

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
			
		State.WANDER:
			wander_to_spotlight(delta)
			current_state = "Wander"

	move_and_slide()
	
	#Check for Collision with Enemy Holder
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var hit_body := collision.get_collider() as Node3D

		#ENEMY HOLDER
		if hit_body and hit_body.is_in_group("enemy_holder"):
			state = State.STUCK
			print("YES - enemy stuck")
			
		#WALL TRIGGER
		if hit_body and hit_body.is_in_group("wall_trigger"):
			state = State.STUCK
			print("WALL TRIGGER")
	
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
	
func wander_to_spotlight(delta: float) -> void:
	# Godot-Vorwärtsrichtung ist die negative Z-Achse.
	var target_angle := atan2(wander_direction.x, wander_direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, 8.0 * delta)

	velocity.x = wander_direction.x * speed
	velocity.z = wander_direction.z * speed

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
	if state != State.WANDER:
		if body.is_in_group("Player"):
			player = body
			state = State.CHASE
			print("PLAYER COLLISION")
		
func _on_area_of_sight_2_body_entered(body: Node3D) -> void:
	if state != State.WANDER:
		if body.is_in_group("Player"):
			player = body
			state = State.CHASE
			print("PLAYER COLLISION2")

func _on_area_of_sight_body_exited(body: Node3D) -> void:
	#player = null
	#state = State.PATROL
	#print("PLAYER EXIT")
	pass

func _on_spotlight_destroyed() -> void:
	if is_queued_for_deletion():
		return

	if is_instance_valid(area_of_sight):
		area_of_sight.queue_free()

	# Spotlight2 ist noch vorhanden: dessen Richtung merken.
	if is_instance_valid(spotlight2):
		set_wander_direction(spotlight2)

	spotlight_was_destroyed()


func _on_spotlight2_destroyed() -> void:
	if is_queued_for_deletion():
		return

	if is_instance_valid(area_of_sight2):
		area_of_sight2.queue_free()

	# Spotlight1 ist noch vorhanden: dessen Richtung merken.
	if is_instance_valid(spotlight):
		set_wander_direction(spotlight)

	spotlight_was_destroyed()


func set_wander_direction(remaining_spotlight: Area3D) -> void:
	wander_direction = remaining_spotlight.global_transform.basis.z
	wander_direction.y = 0
	wander_direction = wander_direction.normalized()


func spotlight_was_destroyed() -> void:
	if not is_inside_tree():
		return
		
	remaining_spotlights -= 1
	print("Verbleibende Spotlights: ", remaining_spotlights)

	if remaining_spotlights <= 0:
		get_tree().call_group("ui_control", "show_enemy_defeated")
		queue_free()
		return

	state = State.WANDER
