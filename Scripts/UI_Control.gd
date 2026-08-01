extends Node

@onready var darkness_label = $DarknessLevel

func _process(delta: float) -> void:
	darkness_label.text = str(roundi(Globals.darkness_level))
