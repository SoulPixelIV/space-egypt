extends Area3D

var collected := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if collected:
		return

	if body.is_in_group("Player"):
		collected = true
		Globals.secrets += 1
		queue_free()
