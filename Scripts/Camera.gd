extends SpringArm3D

@export_range(0.0, 0.5) var mouse_sensitivity = 0.003
@export_range(0.0, 90) var tilt_limit = 70
@export_range(0.0, 1.0) var damping = 0.12
@export var shoulder_offset := Vector3(1.6, 0.8, -2)
@export var offset_speed := 8.0

var following: Node3D = null
var x_target = 0.0
var y_target = 0.0
var current_offset := Vector3.ZERO

func _process(delta: float) -> void:
	if following:
		var target_offset = Vector3.ZERO

		if Input.is_action_pressed("aim"):
			target_offset = shoulder_offset

		current_offset = current_offset.lerp(target_offset, offset_speed * delta)

		global_position = following.global_position \
			+ global_transform.basis.x * current_offset.x \
			+ global_transform.basis.y * current_offset.y \
			+ global_transform.basis.z * current_offset.z
		
		rotation.x = lerp_angle(rotation.x, x_target, damping)
		rotation.y = lerp_angle(rotation.y, y_target, damping)
		
		var tilt_radians = deg_to_rad(tilt_limit)
		rotation.x = clamp(rotation.x, -tilt_radians , tilt_radians)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		x_target -= event.relative.y * mouse_sensitivity
		y_target -= event.relative.x * mouse_sensitivity

func set_following(node) -> void:
	if following != null:
		remove_excluded_object(following)
	following = node
	add_excluded_object(node)
