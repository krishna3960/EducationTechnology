# BarChartControl – a self-drawing horizontal bar chart with hover tooltips.
class_name BarChartControl
extends Control

# Array of Dicts: { "label": String, "value": float, "color": Color }
@export var chart_data: Array = []
@export var bg_color: Color = Color(0.10, 0.13, 0.20, 1.0)

var _progress: float = 0.0
var _hovered_bar: int = -1
var _tt_panel: PanelContainer = null

const ANIM_DURATION: float  = 0.9
const BAR_CORNER_RADIUS: int = 4
const LABEL_W: float        = 72.0
const BAR_H_RATIO: float    = 0.55   # bar height as fraction of row height

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if has_meta("tooltip_panel"):
		_tt_panel = get_meta("tooltip_panel") as PanelContainer

func animate_in() -> void:
	_progress = 0.0
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void:
		_progress = v
		queue_redraw()
	, 0.0, 1.0, ANIM_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2.ZERO, size), bg_color, true, -1.0)

	if chart_data.is_empty():
		return

	var max_val: float = 0.0
	for d: Dictionary in chart_data:
		max_val = max(max_val, float(d.get("value", 0.0)))
	if max_val == 0.0:
		return

	var n: int       = chart_data.size()
	var row_h: float = size.y / float(n)
	var bar_h: float = row_h * BAR_H_RATIO
	var bar_area_w: float = size.x - LABEL_W - 8.0

	for i: int in n:
		var d: Dictionary   = chart_data[i]
		var val: float      = float(d.get("value", 0.0))
		var col: Color      = d.get("color", Color.WHITE)
		var is_hov: bool    = (i == _hovered_bar)

		var y: float        = row_h * i + (row_h - bar_h) * 0.5
		var bar_w: float    = bar_area_w * (val / max_val) * _progress
		var bar_x: float    = LABEL_W

		# Track bar rect
		var bar_rect := Rect2(bar_x, y, bar_w, bar_h)

		# Background track
		var track_col := Color(col.r, col.g, col.b, 0.15)
		draw_rect(Rect2(bar_x, y, bar_area_w, bar_h), track_col, true, -1.0)

		# Filled bar
		var fill_col: Color = col.lightened(0.15) if is_hov else col
		if bar_w > 0:
			draw_rect(bar_rect, fill_col, true, -1.0)

		# Label (left side)
		var lbl_str: String = d.get("label", "")
		draw_string(ThemeDB.fallback_font,
			Vector2(0, y + bar_h * 0.5 + 5),
			lbl_str,
			HORIZONTAL_ALIGNMENT_LEFT, LABEL_W - 4, 13,
			Color.WHITE)

		# Value text on bar (only if bar wide enough)
		if bar_w > 30 and _progress > 0.5:
			var val_str: String = "%.0f" % val
			draw_string(ThemeDB.fallback_font,
				Vector2(bar_x + bar_w - 28, y + bar_h * 0.5 + 5),
				val_str,
				HORIZONTAL_ALIGNMENT_LEFT, 60, 13,
				Color.WHITE)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hover(event.position)

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_hovered_bar = -1
		_show_tooltip(-1, Vector2.ZERO)
		queue_redraw()

func _update_hover(mouse_pos: Vector2) -> void:
	if chart_data.is_empty():
		return
	var n: int = chart_data.size()
	var row_h: float = size.y / float(n)
	var found: int = int(mouse_pos.y / row_h)
	found = clamp(found, 0, n - 1)

	if found != _hovered_bar:
		_hovered_bar = found
		_show_tooltip(found, mouse_pos)
		queue_redraw()

func _show_tooltip(bar_idx: int, mouse_pos: Vector2) -> void:
	if _tt_panel == null:
		if has_meta("tooltip_panel"):
			_tt_panel = get_meta("tooltip_panel") as PanelContainer
		else:
			return
	if bar_idx < 0 or bar_idx >= chart_data.size():
		_tt_panel.visible = false
		return

	var d: Dictionary = chart_data[bar_idx]
	var lbl := _tt_panel.get_node_or_null("TipLabel") as Label
	if lbl:
		lbl.text = "%s: %.0f" % [d.get("label", ""), float(d.get("value", 0.0))]

	var gmp: Vector2 = get_global_mouse_position()
	_tt_panel.position = gmp + Vector2(14, -30)
	_tt_panel.visible = true
