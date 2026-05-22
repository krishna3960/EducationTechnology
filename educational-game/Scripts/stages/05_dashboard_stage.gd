# 05_dashboard_stage.gd
# Stage wrapper for the final dashboard scene.
# Follows the same pattern as 02_shop_stage.gd / classroom_transition.gd.
extends Stage

const DASHBOARD_SCENE := preload("res://Scenes/Dashboard.tscn")
var _dashboard: CanvasLayer

func _stage_start() -> void:
	Stage.set_world_camera_enabled(false)
	_dashboard = DASHBOARD_SCENE.instantiate()
	add_child(_dashboard)
	_dashboard.exit_requested.connect(func() -> void: finished.emit())

func _stage_end() -> void:
	Stage.set_world_camera_enabled(true)
	if _dashboard:
		_dashboard.queue_free()
