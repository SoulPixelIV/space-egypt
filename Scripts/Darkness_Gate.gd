extends MeshInstance3D

@onready var wall_body: StaticBody3D = $StaticBody3D
@onready var wall_collision: CollisionShape3D = $StaticBody3D/CollisionShape3D

var is_passable := false

func _ready() -> void:
	var material := get_active_material(0) as StandardMaterial3D
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func _process(_delta: float) -> void:
	var should_be_passable: bool = Globals.darkness_level < 50.0

	if should_be_passable != is_passable:
		set_wall_state(should_be_passable)

func set_wall_state(passable: bool) -> void:
	is_passable = passable

	var material := get_active_material(0) as StandardMaterial3D

	if passable:
		material.albedo_color.a = 0.4
		wall_collision.set_deferred("disabled", true)
	else:
		material.albedo_color.a = 1.0
		wall_collision.set_deferred("disabled", false)
