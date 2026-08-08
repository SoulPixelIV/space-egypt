extends Area3D

var collected := false

@onready var ui: Control = %UI

func _on_body_entered(body: Node3D) -> void:
	print("ENTERED")

	if body.is_in_group("Player"):
		collected = true
		Globals.secrets += 1
		ui.show_secret_collected()
		get_parent().queue_free()
