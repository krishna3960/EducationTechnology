# Toggleable debug panel anchored top-right.
# Other systems can add their own buttons with e.g. Debug.add_button / Debug.add_checkbox / Debug.add_spinbox.
extends Node

const _TOGGLE_KEY: Key = KEY_F3

# Constants
const _HINT_VISIBLE_TIME: float = 5.0
const _HINT_FADE_TIME: float = 1.0
const _BODY_FONT_SIZE: int = 15
const _HEADER_FONT_SIZE: int = 17
const _HEADER_EMBOLDEN: float = 0.6

@onready var _panel: Control = $UILayer/Panel
@onready var _items: VBoxContainer = $UILayer/Panel/Margin/VBox/Scroll/Items
@onready var _hint: Label = $UILayer/Hint
@onready var _ui_layer: CanvasLayer = $UILayer

var _bold_font: FontVariation

func _ready() -> void:
	_ui_layer.layer = RenderLayers.DEBUG_OVERLAY
	_panel.visible = false
	_bold_font = FontVariation.new()
	_bold_font.base_font = ThemeDB.fallback_font
	_bold_font.variation_embolden = _HEADER_EMBOLDEN
	if not OS.is_debug_build():
		_hint.visible = false
		return
	_fade_hint()

func toggle_debug_panel() -> void:
	_panel.visible = OS.is_debug_build() and not _panel.visible

## Returns a sub-container in the panel.
func add_section(label: String = "") -> VBoxContainer:
	var section := VBoxContainer.new()
	_items.add_child(section)
	add_separator(label, section)
	return section

## Append a button to the panel. The callback fires when the user clicks it.
func add_button(label: String, callback: Callable, parent: Node = _items) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.pressed.connect(callback)
	_apply_body(btn)
	parent.add_child(btn)
	return btn

## Append a checkbox bound to a callback (fires with the new bool on each toggle).
func add_checkbox(label: String, default: bool, on_toggled: Callable, parent: Node = _items) -> CheckBox:
	var cb := CheckBox.new()
	cb.text = label
	cb.button_pressed = default
	cb.toggled.connect(on_toggled)
	_apply_body(cb)
	parent.add_child(cb)
	return cb

## Append a numeric input. By default the range is unbounded.
func add_spinbox(
		label: String,
		default: float,
		on_changed: Callable,
		min_val: float = -INF,
		max_val: float = INF,
		step: float = 1.0,
		parent: Node = _items) -> SpinBox:
	var sb := SpinBox.new()
	sb.prefix = label
	sb.allow_lesser = is_inf(min_val)
	sb.allow_greater = is_inf(max_val)
	sb.min_value = min_val
	sb.max_value = max_val
	sb.step = step
	sb.value = default
	sb.value_changed.connect(on_changed)
	_apply_body(sb)
	parent.add_child(sb)
	return sb

## Append a dropdown of options. Fires `on_selected(index)` whenever an item is picked.
## Pass default_index = -1 to start with nothing selected (so the first pick fires).
func add_option(items: Array, default_index: int, on_selected: Callable, parent: Node = _items) -> OptionButton:
	var ob := OptionButton.new()
	for item in items:
		ob.add_item(str(item))
	ob.select(default_index)
	ob.item_selected.connect(on_selected)
	_apply_body(ob)
	parent.add_child(ob)
	return ob

## Append a static text label.
func add_label(text: String, parent: Node = _items) -> Label:
	var lbl := Label.new()
	lbl.text = text
	_apply_body(lbl)
	parent.add_child(lbl)
	return lbl

## Append a horizontal divider with an optional label on the left of it
func add_separator(label: String = "", parent: Node = _items) -> void:
	if label == "":
		parent.add_child(HSeparator.new())
		return
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label
	lbl.add_theme_font_size_override("font_size", _HEADER_FONT_SIZE)
	lbl.add_theme_font_override("font", _bold_font)
	var sep := HSeparator.new()
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl)
	row.add_child(sep)
	parent.add_child(row)


func _apply_body(c: Control) -> void:
	c.add_theme_font_size_override("font_size", _BODY_FONT_SIZE)

func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == _TOGGLE_KEY:
		toggle_debug_panel()
		get_viewport().set_input_as_handled()

func _fade_hint() -> void:
	var tween := create_tween()
	tween.tween_interval(_HINT_VISIBLE_TIME)
	tween.tween_property(_hint, "modulate:a", 0.0, _HINT_FADE_TIME)
	tween.tween_callback(_hint.hide)
