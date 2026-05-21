extends Node

# Put game state in here. Statically accessible.

enum LandLocation { NONE, FIRST, SECOND, THIRD, FOURTH }

var skip_scenes_enabled: bool = true
var user_consented: bool = false
var electricity_choice: String = ""
var current_stage_index: int = 0
var land_location: LandLocation = LandLocation.NONE

var metrics: Metrics = Metrics.new()


func _ready() -> void:
	metrics.session.debug = OS.is_debug_build()
	Debug.add_separator("Scenes")
	Debug.add_button("Open Shop", func(): get_tree().change_scene_to_file("res://Scenes/Shop.tscn"))
