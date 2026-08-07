extends Node

var max_enemy_count: int = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	var current_enemy_count := get_tree().get_nodes_in_group("enemy").size()

	# Speichert die Gegneranzahl einmal, sobald Gegner vorhanden sind.
	if max_enemy_count == 0 and current_enemy_count > 0:
		max_enemy_count = current_enemy_count
	# Alle Gegner leben = hell (0).
	# Keine Gegner leben = dunkel (100).
	if max_enemy_count > 0:
		Globals.darkness_level = 100.0 * (1.0 - float(current_enemy_count) / float(max_enemy_count))
	else:
		Globals.darkness_level = 100.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_level"):
		get_tree().reload_current_scene()
