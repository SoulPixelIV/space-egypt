extends SpringArm3D

@export_range(0.0, 0.5) var mouse_sensitivity = 0.003
@export_range(0.0, 90) var tilt_limit = 70
@export_range(0.0, 1.0) var damping = 0.12

var following: Node3D = null
var x_target = 0.0
var y_target = 0.0

func _process(delta: float) -> void:
	if following:
		global_position = following.global_position
		
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
