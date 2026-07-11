extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var camera: Node3D

func _ready() -> void:
	camera = %Camera
	camera.set_following(self)

func _physics_process(delta: float) -> void:
	#Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	#Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = input_dir.rotated(-camera.rotation.y)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	#Rotate Player to Camera Direction
	rotation.y = camera.rotation.y

	move_and_slide()
