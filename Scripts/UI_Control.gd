extends Node

@onready var darkness_label = $DarknessLevel
@onready var message_label = $MessageText

func _ready() -> void:
	add_to_group("ui_control")
	message_label.text = ""

func _process(delta: float) -> void:
	darkness_label.text = str(roundi(Globals.darkness_level))
	
func show_enemy_defeated() -> void:
	message_label.text = "Enemy defeated. The Darkness returns..."
	await get_tree().create_timer(3.0).timeout
	message_label.text = ""
