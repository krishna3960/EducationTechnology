# Toggleable debug panel anchored top-right.
# Other systems can add their own buttons with e.g  Debug.add_button / add_checkbox / add_spinbox.
extends Node

const _TOGGLE_KEY: Key = KEY_F3


# Constants
const _HINT_VISIBLE_TIME: float = 5.0
const _HINT_FADE_TIME: float = 1.0



@onready var _panel: Control = $UILayer/Panel
@onready var _items: VBoxContainer = $UILayer/Panel/Margin/VBox/Items
@onready var _hint: Label = $UILayer/Hint


func _ready() -> void:
	_panel.visible = false




	_fade_hint()

func toggleDebugPanel() -> void:
	_panel.visible = not _panel.visible

func add_button(label: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.pressed.connect(callback)
	_items.add_child(btn)
	return btn

func add_checkbox(label: String, default: bool, on_toggled: Callable) -> CheckBox:
	var cb := CheckBox.new()
	cb.text = label
	cb.button_pressed = default
	cb.toggled.connect(on_toggled)
	_items.add_child(cb)
	return cb

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

func add_separator(label: String = "") -> void:
	if label != "":
		var lbl := Label.new()
		lbl.text = label
		_items.add_child(lbl)
	_items.add_child(HSeparator.new())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == _TOGGLE_KEY:
		toggleDebugPanel()
		get_viewport().set_input_as_handled()


func _fade_hint() -> void:
	var tween := create_tween()
	tween.tween_interval(_HINT_VISIBLE_TIME)
	tween.tween_property(_hint, "modulate:a", 0.0, _HINT_FADE_TIME)
	tween.tween_callback(_hint.hide)
