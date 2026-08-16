extends CharacterBody3D

const SPEED = 7.2
const AIM_SPEED = 2.1
const JUMP_VELOCITY = 4.5
@export var shoot_cooldown := 0.5
@export var hp = 100

var camera: Node3D

var currently_aiming = false
var can_shoot := true

@export var bullet: PackedScene

@onready var shoot_point = $ShootPoint

func _ready() -> void:
	camera = %Camera
	camera.set_following(self)

func _physics_process(delta: float) -> void:
	# Shooting
	if Input.is_action_just_pressed("shoot") and can_shoot and currently_aiming:
		weapon_shooting()
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true
		
	#Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	#Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = input_dir.rotated(-camera.rotation.y)
	
	if !currently_aiming:
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.y * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		if direction:
			velocity.x = direction.x * AIM_SPEED
			velocity.z = direction.y * AIM_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, AIM_SPEED)
			velocity.z = move_toward(velocity.z, 0, AIM_SPEED)

	#Rotate Player to Camera Direction
	rotation.y = camera.rotation.y

	move_and_slide()
	
	#Death
	if hp <= 0:
		get_tree().reload_current_scene()

func weapon_shooting():
	var bullet_inst = bullet.instantiate()
	get_tree().current_scene.add_child(bullet_inst)
	
	$AudioStreamPlayer3D.play()

	bullet_inst.global_position = shoot_point.global_position

	# Kamerarichtung
	bullet_inst.direction = -camera.global_transform.basis.z

func play_enemy_defeated_sound() -> void:
	$DarknessSound.play()
