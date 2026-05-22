# PieChartControl – a self-drawing pie chart with hover tooltips.
# Drop into any scene; set chart_data before adding to the tree.
class_name PieChartControl
extends Control

# Array of Dicts: { "label": String, "value": float, "color": Color }
@export var chart_data: Array = []
@export var bg_color: Color = Color(0.10, 0.13, 0.20, 1.0)

# Animation state (0.0 – 1.0)
var _progress: float = 0.0
var _hovered_slice: int = -1

# Tooltip panel reference (set by dashboard.gd via set_meta)
var _tt_panel: PanelContainer = null

const ANIM_DURATION: float = 1.2
const INNER_RATIO:   float = 0.42   # donut hole size

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Retrieve tooltip panel stored by dashboard builder
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
	var cx: float = size.x * 0.5
	var cy: float = size.y * 0.5
	var radius: float = min(cx, cy) - 6.0

	# Background circle
	draw_circle(Vector2(cx, cy), radius + 4, bg_color)

	if chart_data.is_empty():
		return

	var total: float = 0.0
	for d: Dictionary in chart_data:
		total += float(d.get("value", 0.0))
	if total == 0.0:
		return

	var start_angle: float = -PI * 0.5
	var slices_to_draw: int = chart_data.size()

	for i: int in slices_to_draw:
		var d: Dictionary = chart_data[i]
		var fraction: float = float(d.get("value", 0.0)) / total
		var sweep: float    = TAU * fraction * _progress
		var col: Color      = d.get("color", Color.WHITE)

		# Hover highlight
		var is_hovered: bool = (i == _hovered_slice)
		var r_outer: float   = radius + (8.0 if is_hovered else 0.0)
		var r_inner: float   = radius * INNER_RATIO

		# Draw arc as polygon points
		var pts: PackedVector2Array = PackedVector2Array()
		var steps: int = max(8, int(sweep / 0.05))
		# Outer arc
		for s: int in steps + 1:
			var a: float = start_angle + sweep * (float(s) / float(steps))
			pts.append(Vector2(cx + cos(a) * r_outer, cy + sin(a) * r_outer))
		# Inner arc (reverse)
		for s: int in steps + 1:
			var a: float = start_angle + sweep * (float(steps - s) / float(steps))
			pts.append(Vector2(cx + cos(a) * r_inner, cy + sin(a) * r_inner))

		if pts.size() >= 3:
			draw_colored_polygon(pts, col)

		start_angle += sweep

	# Centre label showing hovered slice info
	if _hovered_slice >= 0 and _hovered_slice < chart_data.size():
		var hd: Dictionary = chart_data[_hovered_slice]
		var pct: float = float(hd.get("value", 0.0)) / total * 100.0
		draw_string(ThemeDB.fallback_font,
			Vector2(cx, cy - 8),
			"%s" % hd.get("label", ""),
			HORIZONTAL_ALIGNMENT_CENTER, -1, 14,
			Color.WHITE)
		draw_string(ThemeDB.fallback_font,
			Vector2(cx, cy + 12),
			"%.0f%%" % pct,
			HORIZONTAL_ALIGNMENT_CENTER, -1, 18,
			hd.get("color", Color.WHITE))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hover(event.position)

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_hovered_slice = -1
		_show_tooltip(-1, Vector2.ZERO)
		queue_redraw()

func _update_hover(mouse_pos: Vector2) -> void:
	var cx: float = size.x * 0.5
	var cy: float = size.y * 0.5
	var radius: float = min(cx, cy) - 6.0
	var center := Vector2(cx, cy)
	var delta := mouse_pos - center
	var dist: float = delta.length()

	if dist > radius or dist < radius * INNER_RATIO:
		if _hovered_slice != -1:
			_hovered_slice = -1
			_show_tooltip(-1, mouse_pos)
			queue_redraw()
		return

	var angle: float = atan2(delta.y, delta.x) + PI * 0.5
	if angle < 0.0:
		angle += TAU

	var total: float = 0.0
	for d: Dictionary in chart_data:
		total += float(d.get("value", 0.0))

	var cumulative: float = 0.0
	var found: int = -1
	for i: int in chart_data.size():
		var fraction: float = float(chart_data[i].get("value", 0.0)) / total
		cumulative += TAU * fraction
		if angle <= cumulative:
			found = i
			break

	if found != _hovered_slice:
		_hovered_slice = found
		_show_tooltip(found, mouse_pos)
		queue_redraw()

func _show_tooltip(slice_idx: int, mouse_pos: Vector2) -> void:
	if _tt_panel == null:
		if has_meta("tooltip_panel"):
			_tt_panel = get_meta("tooltip_panel") as PanelContainer
		else:
			return
	if slice_idx < 0 or slice_idx >= chart_data.size():
		_tt_panel.visible = false
		return

	var d: Dictionary = chart_data[slice_idx]
	var total: float = 0.0
	for dd: Dictionary in chart_data:
		total += float(dd.get("value", 0.0))
	var pct: float = float(d.get("value", 0.0)) / total * 100.0

	var lbl := _tt_panel.get_node_or_null("TipLabel") as Label
	if lbl:
		lbl.text = "%s: %.0f%%" % [d.get("label", ""), pct]

	# Position relative to global mouse
	var gmp: Vector2 = get_global_mouse_position()
	_tt_panel.position = gmp + Vector2(14, -30)
	_tt_panel.visible = true
