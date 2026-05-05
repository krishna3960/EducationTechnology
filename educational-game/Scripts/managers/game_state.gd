extends Node

# Put game state in here. Statically accessible.

var current_stage_index: int = 0

func _ready() -> void:
	Debug.add_separator("Scenes")
	Debug.add_button("Open Shop", func(): get_tree().change_scene_to_file("res://Scenes/Shop.tscn"))
