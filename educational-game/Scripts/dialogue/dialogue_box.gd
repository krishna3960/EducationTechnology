# Renders a portrait + speech bubble in the bottom-left.
extends Node

const _SFX_ENTER: AudioStream = preload("res://Assets/Music/PromptoOhhh.mp3")

const DIM_ALPHA: float = 0.6
const DIM_FADE_TIME: float = 0.25
const SQUEEZE_AMOUNT_RANGE := Vector2(0.02, 0.04)  # 1.0 - scale_y at peak squash
const SQUEEZE_DURATION_RANGE := Vector2(0.15, 0.29)  # full squeeze + release in seconds
const SQUEEZE_CHARS_RANGE := Vector2i(2, 4)  # squeeze every N revealed non-silent chars
const _SILENT_CHARS: String = " \t\n.,!?;:-—\""

const _ENTER_DURATION: float = 0.35
const _EXIT_DURATION: float = 0.25
const _ENTER_SLIDE_OFFSET: float = -800.0
const _POST_ENTRANCE_DELAY: float = 0.25

const _DEBUG_DEFAULT_PORTRAIT: Texture2D = preload("res://icon.svg")
const _DEBUG_DEFAULT_TEXT: String = "Bla Bla Bla Bla Bla Bla Bla Bla Bla Bla Bla Bla Bla Bla Bla"
const _DEBUG_DEFAULT_SPEAKER: String = "Yapper"
const _DEBUG_CHARS_PER_SEC_RANGE := Vector2(1.0, 200.0)

# Emitted after the dialogue closes. Useful for sequencing follow-up actions.
signal on_close
# Emitted when the typewriter finishes
signal on_typewriter_done

@onready var _ui: Control = $UILayer/Container
@onready var _portrait: TextureRect = $UILayer/Container/Portrait
@onready var _bubble: Panel = $UILayer/Container/Bubble
@onready var _name_label: Label = $UILayer/Container/Bubble/Name
@onready var _label: RichTextLabel = $UILayer/Container/Bubble/Label
@onready var _dim_rect: ColorRect = $DimLayer/DimRect
@onready var _dim_layer: CanvasLayer = $DimLayer
@onready var _ui_layer: CanvasLayer = $UILayer

var _active: bool = false
var _typing: bool = false
var _auto_close: bool = false
var _tween: Tween
var _dim_tween: Tween
var _squeeze_tween: Tween
var _enter_tween: Tween
var _portrait_rest_x: float = 0.0
var _last_char_count: int = 0
var _chars_since_squeeze: int = 0
var _next_squeeze_at: int = 0

var _debug_chars_per_sec: float = DialogueOptions.DEFAULT_CHARS_PER_SEC
var _debug_dim_enabled: bool = false

var _ts_started: float = 0.0
var _ts_skipped: Variant = null
var _ts_ended: float = 0.0
var _current_speaker: String = ""
var _current_text: String = ""
var _current_chars: int = 0

func _ready() -> void:
	_dim_layer.layer = RenderLayers.DIALOG_DIM
	_ui_layer.layer = RenderLayers.DIALOG_UI
	_ui.visible = false
	_dim_rect.modulate.a = 0.0
	_dim_rect.visible = false
	await get_tree().process_frame
	_portrait_rest_x = _portrait.position.x
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
func show_dialogue(portrait: Texture2D, speaker: String, text: String, opts: DialogueOptions = null, sfx: AudioStream = _SFX_ENTER) -> void:
	if _active:
		return
	if opts == null:
		opts = DialogueOptions.new()

	_portrait.texture = portrait
	_name_label.text = speaker
	_label.text = text
	_label.visible_ratio = 0.0

	if _enter_tween and _enter_tween.is_valid():
		_enter_tween.kill()
	_portrait.position.x = _portrait_rest_x + _ENTER_SLIDE_OFFSET
	_bubble.modulate.a = 0.0

	_ui.visible = true
	if sfx:
		MusicManager.play_sfx(sfx)
	_enter_tween = create_tween().set_parallel(true)
	_enter_tween.tween_property(_portrait, "position:x", _portrait_rest_x, _ENTER_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_enter_tween.tween_property(_bubble, "modulate:a", 1.0, _ENTER_DURATION)
	_active = true
	_typing = true
	_auto_close = opts.auto_close

	_ts_started = Time.get_unix_time_from_system()
	_ts_skipped = null
	_ts_ended = 0.0
	_current_speaker = speaker
	_current_text = text
	_current_chars = text.length()

	if opts.dim:
		_fade_dim(DIM_ALPHA)

	_last_char_count = 0
	_chars_since_squeeze = 0
	_next_squeeze_at = randi_range(SQUEEZE_CHARS_RANGE.x, SQUEEZE_CHARS_RANGE.y)


	_portrait.pivot_offset = Vector2(
		(_portrait.offset_right - _portrait.offset_left) * 0.5,
		_portrait.offset_bottom - _portrait.offset_top
	)
	_portrait.scale = Vector2.ONE

	# Wait for some time after the animation before starting to speak
	await get_tree().create_timer(_ENTER_DURATION + _POST_ENTRANCE_DELAY).timeout
	if not _active:
		return
	if not _typing:
		return

	var duration: float = float(text.length()) / maxf(opts.chars_per_sec, 1.0)
	_tween = create_tween()
	_tween.tween_method(_on_typewriter_progress, 0.0, 1.0, duration)
	_tween.finished.connect(_handle_typewriter_done)

## Close dialog manually
func dismiss() -> void:
	if _active:
		_close()

# Left-click or ui_accept skips to the end of typewriter animation, or dismisses the dialog if already finished (when auto_close is true).
func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	var is_left_click: bool = event is InputEventMouseButton \
		and event.pressed \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	var advance: bool = is_left_click or event.is_action_pressed("ui_accept")
	if not advance:
		return
	if _typing:
		get_viewport().set_input_as_handled()
		_finish_typing()
	elif _auto_close:
		get_viewport().set_input_as_handled()
		_close()

## Skip to the end of the typewriter effect.
func _finish_typing() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	if _enter_tween and _enter_tween.is_valid():
		_enter_tween.kill()
		_portrait.position.x = _portrait_rest_x
		_bubble.modulate.a = 1.0
	_label.visible_ratio = 1.0
	_typing = false
	_stop_squeeze()
	_ts_skipped = Time.get_unix_time_from_system()
	_ts_ended = _ts_skipped
	on_typewriter_done.emit()

func _handle_typewriter_done() -> void:
	_typing = false
	_stop_squeeze()
	_ts_ended = Time.get_unix_time_from_system()
	on_typewriter_done.emit()

func _close() -> void:
	if not _active:
		return
	_active = false
	_auto_close = true
	_stop_squeeze()
	if _enter_tween and _enter_tween.is_valid():
		_enter_tween.kill()
	_fade_dim(0.0)
	_enter_tween = create_tween().set_parallel(true)
	_enter_tween.tween_property(_portrait, "position:x", _portrait_rest_x + _ENTER_SLIDE_OFFSET, _EXIT_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_enter_tween.tween_property(_bubble, "modulate:a", 0.0, _EXIT_DURATION)
	await _enter_tween.finished
	_ui.visible = false
	var ts_closed: float = Time.get_unix_time_from_system()
	var entry := Metrics.DialogueEntry.new()
	entry.speaker = _current_speaker
	entry.text = _current_text
	entry.chars = _current_chars
	entry.ts_started = _ts_started
	entry.ts_skipped = _ts_skipped
	entry.ts_ended = _ts_ended
	entry.ts_closed = ts_closed
	entry.ts_duration = ts_closed - _ts_ended
	GameState.metrics.dialogues.append(entry)
	on_close.emit()

# Call when the typewriter effect progresses. Shows the "squeeze" animation every certain amount of non-silent characters
func _on_typewriter_progress(ratio: float) -> void:
	_label.visible_ratio = ratio
	var text_len: int = _label.text.length()
	var current: int = int(ratio * text_len)
	while _last_char_count < current:
		var ch: String = _label.text.substr(_last_char_count, 1)
		_last_char_count += 1
		if _SILENT_CHARS.contains(ch):
			continue
		_chars_since_squeeze += 1
		if _chars_since_squeeze >= _next_squeeze_at:
			_trigger_squeeze()
			_chars_since_squeeze = 0
			_next_squeeze_at = randi_range(SQUEEZE_CHARS_RANGE.x, SQUEEZE_CHARS_RANGE.y)

func _trigger_squeeze() -> void:
	if _squeeze_tween and _squeeze_tween.is_valid():
		_squeeze_tween.kill()
	var amount: float = randf_range(SQUEEZE_AMOUNT_RANGE.x, SQUEEZE_AMOUNT_RANGE.y)
	var dur: float = randf_range(SQUEEZE_DURATION_RANGE.x, SQUEEZE_DURATION_RANGE.y)
	_squeeze_tween = create_tween()
	_squeeze_tween.tween_property(_portrait, "scale:y", 1.0 - amount, dur * 0.4) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_squeeze_tween.tween_property(_portrait, "scale:y", 1.0, dur * 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _stop_squeeze() -> void:
	if _squeeze_tween and _squeeze_tween.is_valid():
		_squeeze_tween.kill()
	_portrait.scale = Vector2.ONE

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
	show_dialogue(_DEBUG_DEFAULT_PORTRAIT, _DEBUG_DEFAULT_SPEAKER, _DEBUG_DEFAULT_TEXT, opts)
