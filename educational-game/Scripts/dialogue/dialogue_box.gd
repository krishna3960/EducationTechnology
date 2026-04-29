# Renders a portrait + speech bubble in the bottom-left.
extends Node

const DIM_ALPHA: float = 0.4
const DIM_FADE_TIME: float = 0.25

const _DEBUG_DEFAULT_PORTRAIT: Texture2D = preload("res://icon.svg")
const _DEBUG_DEFAULT_TEXT: String = "Triggered from the debug overlay."
const _DEBUG_CHARS_PER_SEC_RANGE := Vector2(1.0, 200.0)

# Emitted after the dialogue closes. Useful for sequencing follow-up actions.
signal dialogue_finished

@onready var _ui: Control = $UILayer/Container
@onready var _portrait: TextureRect = $UILayer/Container/Portrait
@onready var _label: RichTextLabel = $UILayer/Container/Bubble/Label
@onready var _dim_rect: ColorRect = $DimLayer/DimRect

var _active: bool = false
var _typing: bool = false
var _tween: Tween
var _dim_tween: Tween

var _debug_chars_per_sec: float = DialogueOptions.DEFAULT_CHARS_PER_SEC
var _debug_dim_enabled: bool = false

func _ready() -> void:
	_ui.visible = false
	_dim_rect.modulate.a = 0.0
	_dim_rect.visible = false
	if OS.is_debug_build():
		Debug.add_separator("Dialogue")
		Debug.add_button("Trigger Dialogue", _trigger_debug_dialogue)
		Debug.add_checkbox("Dim", _debug_dim_enabled, func(p): _debug_dim_enabled = p)
		Debug.add_spinbox("Chars/sec ", _debug_chars_per_sec, func(v): _debug_chars_per_sec = v,
			_DEBUG_CHARS_PER_SEC_RANGE.x, _DEBUG_CHARS_PER_SEC_RANGE.y)

## True while a dialogue is on screen (typing or waiting for dismissal).
func is_active() -> bool:
	return _active

## Renders the conversation bubble. If a dialogue is already active, this does nothing.
func show_dialogue(portrait: Texture2D, text: String, opts: DialogueOptions = null) -> void:
	if _active:
		return
	if opts == null:
		opts = DialogueOptions.new()

	_portrait.texture = portrait
	_label.text = text
	_label.visible_ratio = 0.0
	_ui.visible = true
	_active = true
	_typing = true

	if opts.dim:
		_fade_dim(DIM_ALPHA)

	var duration: float = float(text.length()) / maxf(opts.chars_per_sec, 1.0)
	_tween = create_tween()
	_tween.tween_property(_label, "visible_ratio", 1.0, duration)
	_tween.finished.connect(func(): _typing = false)


# Click or ui_accept skips to the end of typewriter animation, or dismisses the dialog if already finished
func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	var advance: bool = (event is InputEventMouseButton and event.pressed) \
		or event.is_action_pressed("ui_accept")
	if not advance:
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_finish_typing()
	else:
		_close()

## Skip to the end of the typewriter effect
func _finish_typing() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_label.visible_ratio = 1.0
	_typing = false

func _close() -> void:
	_ui.visible = false
	_fade_dim(0.0)
	_active = false
	dialogue_finished.emit()

## Fades the dim overlay to a certain alpha
func _fade_dim(target_alpha: float) -> void:
	if _dim_tween and _dim_tween.is_valid():
		_dim_tween.kill()
	_dim_rect.visible = true
	_dim_tween = create_tween()
	_dim_tween.tween_property(_dim_rect, "modulate:a", target_alpha, DIM_FADE_TIME)
	if target_alpha == 0.0:
		_dim_tween.tween_callback(_dim_rect.hide)

func _trigger_debug_dialogue() -> void:
	var opts := DialogueOptions.new()
	opts.dim = _debug_dim_enabled
	opts.chars_per_sec = _debug_chars_per_sec
	show_dialogue(_DEBUG_DEFAULT_PORTRAIT, _DEBUG_DEFAULT_TEXT, opts)
