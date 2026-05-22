extends Stage

@export var speed: float = 0.06
@export var _SPEAKER: String = "Prompto"
@export var full_text_1: String =  "Welcome to “VibeX”. You are the CEO of the AI datacenter company VibeX, responsible for managing infrastructure, expanding operations, and making critical business decisions. Your choices will shape the future of AI services across the region. \n\n Click Next to start"
const _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant_v1.png")
@export var _INTRO_TEXT: String =  "Hello! My name is Prompto, and I’ll be your assistant throughout the game. Before we begin, let me show you the region. \nClick on the screen to continue."
@export var _text_show_pontia: String = "In the top left is the village of Pontia."
@export var _text_show_petalia: String = "In the top center you'll find Petalia."
@export var _text_show_fontania: String = "And on the bottom right is Fontania."
@export var _text_show_datacenter: String = "Your AI datacenter is located in the center. Any buildings, infrastructure, or assets you own will be highlighted in your company's colors."
@export var _text_observation_demand_increase: String = "I monitor AI demand across the region. Recently, I detected a dramatic increase in requests coming from all three villages. Our current infrastructure can no longer keep up with demand. If we do nothing, requests will fail."
@export var _text_user_consent: String = "By continuing, you consent to the collection of interaction data, including clicks and in-game actions, for analytical purposes."

var can_continue := false

var label: RichTextLabel
var label1 : RichTextLabel
var current_index := 0
var current_index_1 := 0
var timer: Timer
var timer1: Timer

var show_hint : bool = true

# Camera slides to these cells during the intro sequence.
const _PONTIA_CELL: Vector2i = Vector2i(-3, -2)
const _PETALIA_CELL: Vector2i = Vector2i(7, -2)
const _FONTANIA_CELL: Vector2i = Vector2i(8, 6)
const _OVERVIEW_CELL: Vector2i = Vector2i(3, 0)

const _CAM_OVERVIEW_ZOOM: Vector2 = Vector2(0.4, 0.4)
# Target zoom when focusing on a specific village or the datacenter.
const _CAM_REGION_ZOOM: Vector2 = Vector2(0.48, 0.48)

const _CAM_PAN_DURATION: float = 1.0
const _PRE_PAN_DELAY: float = 0.6

func _stage_start() -> void:
	#print("hello, now we are in stage 2")
	
	label1 = get_node("UILayer/Control_intro/UserConsentLabel")
	label1.clear()
	

	get_node("UILayer/Control_intro/Button").visible = false
	get_node("UILayer/StartButtonHolder").visible = false
	get_node("UILayer/Control_intro/UserConsentButton").visible = false
	get_node("CanvasLayer/HintButton").visible = false

	timer = Timer.new()
	add_child(timer)

	timer.wait_time = speed
	timer.timeout.connect(func(): current_index = _show_next_char(_text_user_consent, "UILayer/Control_intro/UserConsentButton", label1, timer, current_index))
	#timer.timeout.connect(_show_next_char.bind(full_text_1, "UILayer/Control_intro/Button"))

	await get_tree().create_timer(1.5).timeout

	timer.start()


func _button_pressed():
	get_node("UILayer/Control_intro/Button").hide()
	get_node("UILayer/Control_intro/RichTextLabel").hide()
	get_node("UILayer/Control_intro/DarkTint").hide()
	start_conversation()

	
func _on_user_consent_button_pressed() -> void:
	GameState.user_consented = true
	label = get_node("UILayer/Control_intro/RichTextLabel")

	label.clear()
	get_node("UILayer/Control_intro/UserConsentButton").hide()
	get_node("UILayer/Control_intro/UserConsentLabel").hide()
	timer1 = Timer.new()
	timer1.wait_time = speed
	add_child(timer1)
	timer1.timeout.connect(func(): current_index_1 = _show_next_char(full_text_1, "UILayer/Control_intro/Button", label, timer1, current_index_1))
	
	await get_tree().create_timer(1.5).timeout

	timer1.start()
	

func _pan_camera_to_cell(cell: Vector2i, target_zoom: Vector2, duration: float = _CAM_PAN_DURATION) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null or MapLayer.main == null:
		return
	var target_pos: Vector2 = MapLayer.main.map_to_local(cell)
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	print("target pos is ", target_pos)
	t.tween_property(camera, "position", target_pos, duration)
	t.tween_property(camera, "zoom", target_zoom, duration)



func _show_dialogue_step(text: String) -> void:
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = true
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, text, opts)
	await Dialogue.on_close


## Wait some time, then pan the camera to the specified cell and show a dialogue step.
func _pan_then_show(cell: Vector2i, zoom: Vector2, text: String) -> void:
	await get_tree().create_timer(_PRE_PAN_DELAY).timeout
	_pan_camera_to_cell(cell, zoom)
	await _show_dialogue_step(text)


func start_conversation():
	await _pan_then_show(_OVERVIEW_CELL, _CAM_OVERVIEW_ZOOM, _INTRO_TEXT)
	await _pan_then_show(_PONTIA_CELL, _CAM_REGION_ZOOM, _text_show_pontia)
	await _pan_then_show(_PETALIA_CELL, _CAM_REGION_ZOOM, _text_show_petalia)
	await _pan_then_show(_FONTANIA_CELL, _CAM_REGION_ZOOM, _text_show_fontania)
	await _pan_then_show(MapLayer.DEFAULT_CAMERA_CELL, _CAM_REGION_ZOOM, _text_show_datacenter)
	await _pan_then_show(_OVERVIEW_CELL, _CAM_OVERVIEW_ZOOM, _text_observation_demand_increase)
	finished.emit()

func _start_scene_1():
	finished.emit()


func _stage_end() -> void:
	Dialogue.dismiss()

func _show_next_char(text, button, labels, timers, current_idx):
	if current_idx < text.length():
		labels.append_text(text.substr(current_idx, 1))
		return current_idx + 1
	else:
		timers.stop()
		get_node(button).visible = true
		return current_idx
