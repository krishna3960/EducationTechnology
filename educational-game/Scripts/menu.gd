extends Control

const _SFX_CYCLE: AudioStream = preload("res://Assets/Music/Transition - Sound Effect HD.mp3")
const _SFX_TOGGLE: AudioStream = preload("res://Assets/Music/NewspaperExit.mp3")

const _STAGE_MANAGER_SCENE: PackedScene = preload("res://Scenes/stage_manager.tscn")
const _NAME_PROMPT_SCENE: PackedScene = preload("res://Scenes/NamePrompt.tscn")
const _UI_FADE_DURATION: float = 0.5
const _TINT_FADE_DELAY: float = 0.4
const _TINT_FADE_DURATION: float = 0.8

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.7529412, 0.88235295, 0.3647059))
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
	MusicManager.play_sfx(_SFX_CYCLE)
	# Fade out the menu UI first.
	var ui: Control = $UILayer/CenterContainer
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ui_tween := create_tween()
	ui_tween.tween_property(ui, "modulate:a", 0.0, _UI_FADE_DURATION)
	await ui_tween.finished
	# Then show the name prompt (it fades itself in and out).
	var entered_name: String = await _prompt_player_name()
	GameState.player_name = entered_name
	GameState.metrics.session.player_name = entered_name

	_start_game()


## Spawns the NamePrompt scene; the scene fades itself in on _ready.
## Awaits `submitted`, then asks the scene to fade out before freeing it.
func _prompt_player_name() -> String:
	var prompt: Control = _NAME_PROMPT_SCENE.instantiate()
	add_child(prompt)
	var entered_name: String = await prompt.submitted
	await prompt.fade_out()
	prompt.queue_free()
	return entered_name


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

func _on_settings_pressed() -> void:
	MusicManager.play_sfx(_SFX_CYCLE)
	$UILayer/CenterContainer/Node2D.visible = false
	$UILayer/CenterContainer/SettingsPanel.visible = true
	_update_skip_buttons()

func _on_settings_back_pressed() -> void:
	MusicManager.play_sfx(_SFX_CYCLE)
	$UILayer/CenterContainer/SettingsPanel.visible = false
	$UILayer/CenterContainer/Node2D.visible = true

func _on_skip_false() -> void:
	GameState.skip_scenes_enabled = false
	_update_skip_buttons()

func _on_skip_true() -> void:
	GameState.skip_scenes_enabled = true
	_update_skip_buttons()

func _update_skip_buttons() -> void:
	MusicManager.play_sfx(_SFX_TOGGLE)
	var false_btn: Button = $UILayer/CenterContainer/SettingsPanel/VBox/SkipRow/FalseButton
	var true_btn: Button = $UILayer/CenterContainer/SettingsPanel/VBox/SkipRow/TrueButton
	var active := Color(1.0, 1.0, 0.4, 1.0)
	var inactive := Color(0.6, 0.6, 0.6, 1.0)
	false_btn.modulate = inactive if GameState.skip_scenes_enabled else active
	true_btn.modulate = active if GameState.skip_scenes_enabled else inactive

func _on_quit_pressed() -> void:
	MusicManager.play_sfx(_SFX_CYCLE)
	get_tree().quit()
