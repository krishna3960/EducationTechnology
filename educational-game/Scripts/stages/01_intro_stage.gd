extends Stage

@export var speed: float = 0.025
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

# Camera slides to these cells during the intro sequence.
const _PONTIA_CELL: Vector2i = Vector2i(-3, -2)
const _PETALIA_CELL: Vector2i = Vector2i(7, -2)
const _FONTANIA_CELL: Vector2i = Vector2i(8, 6)
const _OVERVIEW_CELL: Vector2i = Vector2i(3, 0)

const _CAM_OVERVIEW_ZOOM: Vector2 = Vector2(0.4, 0.4)
const _CAM_REGION_ZOOM: Vector2 = Vector2(0.48, 0.48)
const _CAM_PAN_DURATION: float = 1.0
const _PRE_PAN_DELAY: float = 1.0

# Set by _input while the consent/welcome typewriter runs — _run_typewriter
# polls this each tick and bails out to the end of the text when true.
var _typing_skip_requested: bool = false
# True while one of the in-page typewriters is running; lets _input only fire
# the skip logic during those phases.
var _typing_active: bool = false


func _stage_start() -> void:
	# Page nodes the player will see (and the ones we keep hidden for later).
	var consent_label: RichTextLabel = get_node("UILayer/Control_intro/UserConsentLabel")
	var consent_button: Button = get_node("UILayer/Control_intro/UserConsentButton")
	var welcome_label: RichTextLabel = get_node("UILayer/Control_intro/RichTextLabel")
	var welcome_button: Button = get_node("UILayer/Control_intro/Button")
	var dark_tint: Control = get_node("UILayer/DarkTint")

	consent_label.clear()
	welcome_label.clear()
	welcome_label.visible = false
	consent_button.visible = false
	welcome_button.visible = false

	# ----- Consent page -----
	await _run_typewriter(consent_label, _text_user_consent)
	consent_button.visible = true
	await consent_button.pressed
	GameState.user_consented = true
	consent_button.hide()
	consent_label.hide()

	# ----- Welcome page -----
	welcome_label.visible = true
	await _run_typewriter(welcome_label, full_text_1)
	welcome_button.visible = true
	await welcome_button.pressed
	welcome_button.hide()
	welcome_label.hide()
	dark_tint.hide()

	# ----- Region dialogues -----
	start_conversation()


## Types `full_text` into `target_label` one character at a time, awaiting `speed`
## seconds per char. Returns once the full text is on screen. Sets
## `_typing_active = true` while running so _input can fast-forward via the
## `_typing_skip_requested` flag.
func _run_typewriter(target_label: RichTextLabel, full_text: String) -> void:
	target_label.clear()
	_typing_active = true
	_typing_skip_requested = false
	for i in full_text.length():
		if _typing_skip_requested:
			target_label.clear()
			target_label.append_text(full_text)
			break
		target_label.append_text(full_text.substr(i, 1))
		await get_tree().create_timer(speed).timeout
	_typing_active = false


func _pan_camera_to_cell(cell: Vector2i, target_zoom: Vector2, duration: float = _CAM_PAN_DURATION) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null or MapLayer.main == null:
		return
	var target_pos: Vector2 = MapLayer.main.map_to_local(cell)
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(camera, "position", target_pos, duration)
	t.tween_property(camera, "zoom", target_zoom, duration)


func _show_dialogue_step(text: String) -> void:
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = true
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, text, opts)
	await Dialogue.on_close


## Wait `_PRE_PAN_DELAY` seconds, then pan the camera to the specified cell and show a dialogue step. The wait lets the previous dialogue's view sit a moment before the next pan starts.
func _pan_then_show(cell: Vector2i, zoom: Vector2, text: String) -> void:
	if _PRE_PAN_DELAY > 0.0:
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


## Left-click or ui_accept fast-forwards the consent/welcome typewriter
## if one is running. The Dialogue autoload handles its own click-to-skip
## for the region dialogues. The click-anywhere hint is dismissed inside
## _show_dialogue_step when the dialogue is actually closed, not on every click.
func _input(event: InputEvent) -> void:
	if not _typing_active:
		return
	var is_left_click: bool = event is InputEventMouseButton \
		and event.pressed \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	if is_left_click or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_typing_skip_requested = true


func _stage_end() -> void:
	Dialogue.dismiss()
