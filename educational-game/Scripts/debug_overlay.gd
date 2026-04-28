# Toggleable debug panel anchored top-right.
# Other systems can add their own buttons with e.g. Debug.add_button / Debug.add_checkbox / Debug.add_spinbox.
extends Node

const _TOGGLE_KEY: Key = KEY_F3

# Constants
const _HINT_VISIBLE_TIME: float = 5.0
const _HINT_FADE_TIME: float = 1.0
## Dialogue
const _DIALOGUE_DEFAULT_PORTRAIT: Texture2D = preload("res://icon.svg")
const _DIALOGUE_DEFAULT: String = "Triggered from the debug overlay."
const _DIALOGUE_CHARS_PER_SEC_RANGE := Vector2(1.0, 200.0)

# Other
var _dialogue_chars_per_sec: float = DialogueOptions.DEFAULT_CHARS_PER_SEC
## Dialogue
var _dialogue_dim_enabled: bool = false

@onready var _panel: Control = $UILayer/Panel
@onready var _items: VBoxContainer = $UILayer/Panel/Margin/VBox/Items
@onready var _hint: Label = $UILayer/Hint

func _ready() -> void:
	_panel.visible = false
	# Dialogue debug components
	add_button("Trigger Dialogue", _on_trigger_dialogue)
	add_checkbox("Dim", _dialogue_dim_enabled, func(p): _dialogue_dim_enabled = p)
	add_spinbox("Chars/sec ", _dialogue_chars_per_sec, func(v): _dialogue_chars_per_sec = v,
		_DIALOGUE_CHARS_PER_SEC_RANGE.x, _DIALOGUE_CHARS_PER_SEC_RANGE.y)
	_fade_hint()

func toggle_debug_panel() -> void:
	_panel.visible = not _panel.visible

## Append a button to the panel. The callback fires when the user clicks it.
func add_button(label: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.pressed.connect(callback)
	_items.add_child(btn)
	return btn

## Append a checkbox bound to a callback (fires with the new bool on each toggle).
func add_checkbox(label: String, default: bool, on_toggled: Callable) -> CheckBox:
	var cb := CheckBox.new()
	cb.text = label
	cb.button_pressed = default
	cb.toggled.connect(on_toggled)
	_items.add_child(cb)
	return cb

## Append a numeric input. By default the range is unbounded.
func add_spinbox(
		label: String,
		default: float,
		on_changed: Callable,
		min_val: float = -INF,
		max_val: float = INF,
		step: float = 1.0) -> SpinBox:
	var sb := SpinBox.new()
	sb.prefix = label
	sb.allow_lesser = is_inf(min_val)
	sb.allow_greater = is_inf(max_val)
	sb.min_value = min_val
	sb.max_value = max_val
	sb.step = step
	sb.value = default
	sb.value_changed.connect(on_changed)
	_items.add_child(sb)
	return sb

## Append a horizontal divider, optionally preceded by a section label.
func add_separator(label: String = "") -> void:
	if label != "":
		var lbl := Label.new()
		lbl.text = label
		_items.add_child(lbl)
	_items.add_child(HSeparator.new())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == _TOGGLE_KEY:
		toggle_debug_panel()
		get_viewport().set_input_as_handled()

func _on_trigger_dialogue() -> void:
	var opts := DialogueOptions.new()
	opts.dim = _dialogue_dim_enabled
	opts.chars_per_sec = _dialogue_chars_per_sec
	Dialogue.show_dialogue(_DIALOGUE_DEFAULT_PORTRAIT, _DIALOGUE_DEFAULT, opts)

func _fade_hint() -> void:
	var tween := create_tween()
	tween.tween_interval(_HINT_VISIBLE_TIME)
	tween.tween_property(_hint, "modulate:a", 0.0, _HINT_FADE_TIME)
	tween.tween_callback(_hint.hide)
