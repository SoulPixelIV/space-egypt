extends Node

@onready var darkness_label = $DarknessLevel
@onready var message_label = $MessageText
@onready var message2_label = $MessageText2
@onready var secret_label = $SecretLevel

func _ready() -> void:
	add_to_group("ui_control")
	message_label.text = ""
	message2_label.text = ""

func _process(delta: float) -> void:
	darkness_label.text = str(roundi(Globals.darkness_level))
	secret_label.text = str(Globals.secrets)
	if Globals.darkness_level > 80:
		message2_label.text = "Press 'P' to restart Level"
	else:
		message2_label.text = ""
	
func show_enemy_defeated() -> void:
	message_label.text = "Enemy defeated. The Darkness returns..."
	await get_tree().create_timer(3.0).timeout
	message_label.text = ""
	
func show_secret_collected():
	message_label.text = "Secret found!"
	await get_tree().create_timer(3.0).timeout
	message_label.text = ""
