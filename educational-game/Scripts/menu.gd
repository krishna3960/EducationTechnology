extends Control

const _STAGE_MANAGER_SCENE: PackedScene = preload("res://Scenes/stage_manager.tscn")
const _UI_FADE_DURATION: float = 0.5
const _TINT_FADE_DELAY: float = 0.4
const _TINT_FADE_DURATION: float = 0.8

func _ready() -> void:
	var world := get_node_or_null("World")
	if world == null:
		return
	var pause_menu: Node = world.get_node_or_null("PauseMenu")
	if pause_menu:
		pause_menu.set_process_unhandled_input(false)
	var camera: Camera2D = world.get_node_or_null("ground/Camera2D")
	if camera:
		camera.set_process(false)
		camera.set_process_unhandled_input(false)


func _on_play_pressed() -> void:
	var ui: Control = $UILayer/CenterContainer
	var tint: ColorRect = $UILayer/DarkTint
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ui_tween := create_tween()
	ui_tween.tween_property(ui, "modulate:a", 0.0, _UI_FADE_DURATION)
	await ui_tween.finished
	#await get_tree().create_timer(_TINT_FADE_DELAY).timeout
	#var tint_tween := create_tween()
	#tint_tween.tween_property(tint, "color:a", 0.0, _TINT_FADE_DURATION)
	#await tint_tween.finished
	_start_game()


func _start_game() -> void:
	var world := get_node_or_null("World")
	if world:
		var pause_menu: Node = world.get_node_or_null("PauseMenu")
		if pause_menu:
			pause_menu.set_process_unhandled_input(true)
		var camera: Camera2D = world.get_node_or_null("ground/Camera2D")
		if camera:
			camera.set_process(true)
			camera.set_process_unhandled_input(true)
	$UILayer.queue_free()
	GameState.metrics.session.ts_started = Time.get_unix_time_from_system()
	add_child(_STAGE_MANAGER_SCENE.instantiate())


func _on_quit_pressed() -> void:
	get_tree().quit()
