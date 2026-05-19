extends Stage

@export var speed: float = 0.06
@export var _SPEAKER: String = "Prompto"
var full_text_1: String =  "Welcome to “VibeX”. You are the CEO of the AI datacenter company VibeX, responsible for managing infrastructure, expanding operations, and making critical business decisions. Your choices will shape the future of AI services across the region. \n\n Click Next to start"
const _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant_v1.png")
const _INTRO_TEXT: String =  "Hello! My name is Prompto, and I’ll be your assistant throughout the game. Before we begin, let me show you the region."
var _text_show_pontia: String = "In the top left is the village of Pontia."
var _text_show_petalia: String = "In the top center you'll find Petalia."
var _text_show_fontania: String = "And on the bottom right is Fontania."
var _text_show_datacenter: String = "Your AI datacenter is located in the center. Any buildings, infrastructure, or assets you own will be highlighted in your company's colors."
var _text_observation_demand_increase: String = "I monitor AI demand across the region. Recently, I detected a dramatic increase in requests coming from all three villages. Our current infrastructure can no longer keep up with demand. If we do nothing, requests will fail."
var _text_start_stage_1: String = "To secure the future of VibeX, we’ll need to expand the datacenter and carefully manage our resources. The decisions won’t be easy. Are you ready to take on the challenge?"

var can_continue := false

var label: RichTextLabel
var current_index := 0
var timer: Timer

# Camera slides to these cells during the intro sequence.
const _PONTIA_CELL: Vector2i = Vector2i(-3, -2)
const _PETALIA_CELL: Vector2i = Vector2i(7, -2)
const _FONTANIA_CELL: Vector2i = Vector2i(8, 6)
const _OVERVIEW_CELL: Vector2i = Vector2i(3, 0)

const _CAM_OVERVIEW_ZOOM: Vector2 = Vector2(0.40, 0.40)
# Target zoom when focusing on a specific village or the datacenter.
const _CAM_REGION_ZOOM: Vector2 = Vector2(0.48, 0.48)

const _CAM_PAN_DURATION: float = 1.0

func _stage_start() -> void:
	print("hello, now we are in stage 2")

	label = get_node("UILayer/Control_intro/RichTextLabel")

	label.clear()

	get_node("UILayer/Control_intro/Button").visible = false
	get_node("UILayer/StartButtonHolder").visible = false

	get_node("UILayer/DebugSkipButton").visible = OS.is_debug_build()

	timer = Timer.new()
	add_child(timer)

	timer.wait_time = speed
	timer.timeout.connect(_show_next_char)

	await get_tree().create_timer(1.5).timeout

	timer.start()


func _button_pressed():
	get_node("UILayer/Control_intro").hide()
	start_conversation()


func _pan_camera_to_cell(cell: Vector2i, target_zoom: Vector2, duration: float = _CAM_PAN_DURATION) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null or MapLayer.main == null:
		return
	var target_pos: Vector2 = MapLayer.main.map_to_local(cell)
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(camera, "position", target_pos, duration)
	t.tween_property(camera, "zoom", target_zoom, duration)


func start_conversation():
	_pan_camera_to_cell(_OVERVIEW_CELL, _CAM_OVERVIEW_ZOOM)
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = false
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _INTRO_TEXT, opts)

	await get_tree().create_timer(9.0).timeout
	Dialogue.dismiss()

	# show pontia
	_pan_camera_to_cell(_PONTIA_CELL, _CAM_REGION_ZOOM)
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _text_show_pontia, opts)
	await get_tree().create_timer(4.0).timeout
	Dialogue.dismiss()
	opts.dim = false

	# show petalia, then call fontania, then show ai center, finally open the dialog leading to stage one
	_show_petalia()

func _show_petalia():
	await get_tree().create_timer(2.0).timeout
	_pan_camera_to_cell(_PETALIA_CELL, _CAM_REGION_ZOOM)
	var opts := DialogueOptions.new()
	opts.dim = true
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _text_show_petalia, opts)
	await get_tree().create_timer(4.0).timeout
	Dialogue.dismiss()
	opts.dim = false

	_show_fontania()

func _show_fontania():
	await get_tree().create_timer(2.0).timeout
	_pan_camera_to_cell(_FONTANIA_CELL, _CAM_REGION_ZOOM)
	var opts := DialogueOptions.new()
	opts.dim = true
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _text_show_fontania, opts)
	await get_tree().create_timer(4.0).timeout
	Dialogue.dismiss()
	opts.dim = false

	_show_ai_center()

func _show_ai_center():
	await get_tree().create_timer(2.0).timeout
	_pan_camera_to_cell(MapLayer.DEFAULT_CAMERA_CELL, _CAM_REGION_ZOOM)
	var opts := DialogueOptions.new()
	opts.dim = true
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _text_show_datacenter, opts)
	await get_tree().create_timer(10.0).timeout
	Dialogue.dismiss()
	opts.dim = false

	_show_increase_in_demand()


func _show_increase_in_demand():
	await get_tree().create_timer(2.0).timeout
	_pan_camera_to_cell(_OVERVIEW_CELL, _CAM_OVERVIEW_ZOOM)
	var opts := DialogueOptions.new()
	opts.dim = true
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _text_observation_demand_increase, opts)
	await get_tree().create_timer(16.0).timeout
	Dialogue.dismiss()
	_show_switch_to_stage_1()

func _show_switch_to_stage_1():
	#await get_tree().create_timer(2.0).timeout
	var opts := DialogueOptions.new()
	opts.dim = true
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _text_start_stage_1, opts)
	await get_tree().create_timer(12.0).timeout
	Dialogue.dismiss()
	opts.dim = false
	get_node("UILayer/StartButtonHolder").show()
	get_node("UILayer/StartButtonHolder/Button_to_stage_1").show()

func _start_scene_1():
	finished.emit()


func _stage_end() -> void:
	print("end of stage 2")
	Dialogue.dismiss()

func _show_next_char():
	if current_index < full_text_1.length():
		label.append_text(full_text_1.substr(current_index, 1))
		current_index += 1
	else:
		timer.stop()
		get_node("UILayer/Control_intro/Button").visible = true
