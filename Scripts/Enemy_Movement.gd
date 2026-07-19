extends CharacterBody3D

enum State {
	PATROL,
	CHASE
}

const SPEED := 3.5
const ARRIVAL_DISTANCE := 1.0

@export var player: CharacterBody3D

@onready var patrol_points = $"../PatrolPoints".get_children()
@onready var raycast = $RayCast3D

var current_point := 0
var state = State.PATROL

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

	if can_see_player():
		state = State.CHASE
	elif player == null:
		state = State.PATROL

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
	
#Line of Sight	
func can_see_player() -> bool:
	if player == null:
		return false

	# Richtung zum Spieler
	var direction = (player.global_position - global_position).normalized()

	# Blickrichtung des Gegners
	var forward = -transform.basis.z

	# Winkel berechnen
	var angle = rad_to_deg(acos(forward.dot(direction)))

	if angle > 45:
		return false

	# RayCast auf Spieler richten
	raycast.target_position = raycast.to_local(player.global_position)
	raycast.force_raycast_update()

	if raycast.is_colliding():
		return raycast.get_collider() == player

	return false

#Area of Sight
func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		print("PLAYER COLLISION")
		
func _on_area_of_sight_body_exited(body: Node3D) -> void:
	player = null
	state = State.PATROL
	print("PLAYER EXIT")
