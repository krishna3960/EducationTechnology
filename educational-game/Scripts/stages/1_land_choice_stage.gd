extends Stage

@export var _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant_v1.png")
@export var _SPEAKER: String = "Prompto"
@export var _INTRO_TEXT: String = "We need to start by buying some land for the datacenter. Where should we build it?"

const _CHOICES: Dictionary = {
	GameState.LandLocation.FIRST: {
		"tint": Color(0.0, 1.0, 0.0, 0.518),
		"cells": [Vector2i(3, 2), Vector2i(2, 0), Vector2i(4, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 2), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3), Vector2i(2, 4), Vector2i(2, 3), Vector2i(1, 4), Vector2i(0, 4), Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1), Vector2i(1, 2), Vector2i(1, 3)],
		"signs": [Vector2i(4,1)],
	},
	GameState.LandLocation.SECOND: {
		"tint": Color(1.4, 0.0, 0.0, 0.624),
		"cells": [Vector2i(3, 2), Vector2i(3, -1), Vector2i(3, -2), Vector2i(3, 1), Vector2i(4, 2), Vector2i(5, 1), Vector2i(2, 2), Vector2i(1, 1), Vector2i(2, -1), Vector2i(1, -1), Vector2i(4, -1), Vector2i(5, -1), Vector2i(5, 0), Vector2i(4, 0), Vector2i(4, 1), Vector2i(2, 0), Vector2i(2, 1), Vector2i(1, 0)],
		"signs": [Vector2i(4,1)],
	},
	GameState.LandLocation.THIRD: {
		"tint": Color(0.0, 0.0, 1.4, 0.627),
		"cells": [Vector2i(3, 2), Vector2i(2, 0), Vector2i(1, -1), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(-2, 2), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 1), Vector2i(2, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(0, 2), Vector2i(-1, 2)],
		"signs": [Vector2i(3,1)],
	},
	GameState.LandLocation.FOURTH: {
		"tint": Color(0.748, 0.068, 0.85, 0.627),
		"cells": [Vector2i(3, 2), Vector2i(2, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 4), Vector2i(5, 3), Vector2i(6, 3), Vector2i(6, 2), Vector2i(5, 1), Vector2i(4, 1), Vector2i(3, 1), Vector2i(2, 2), Vector2i(4, 2), Vector2i(4, 3), Vector2i(5, 2)],
		"signs": [Vector2i(3,1)],
	},
}

const _HOVER_FADE_DURATION: float = 0.08

const _CONSTRUCTION_TILE: String = "res://Assets/tiles/construction_land_tile.png"
const _CONSTRUCTION_SIGN: String = "res://Assets/tiles/under_construction.png"
const _CONSTRUCTION_MAX_DELAY: float = 1.5
const _SIGN_HOLD_DELAY: float = 1.0
const _NEWSPAPER_DELAY: float = 1.0

var _clump_polygons: Dictionary = {}
var _ui_canvas: CanvasLayer
var _current_choice_index: int = 0
var _choose_btn: Button = null
var _ts_started: float = 0.0


const _DATACENTER_CELL: Vector2i = Vector2i(3, 0)


func _stage_start() -> void:
	_ts_started = Time.get_unix_time_from_system()
	var camera := get_viewport().get_camera_2d()
	if MapLayer.main and camera:
		camera.position = MapLayer.main.map_to_local(_DATACENTER_CELL)
		camera.reset_smoothing()

	Dialogue.on_typewriter_done.connect(_show_choices, CONNECT_ONE_SHOT)
	var opts := DialogueOptions.new()
	opts.dim = false
	opts.auto_close = false
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _INTRO_TEXT, opts)


func _show_choices() -> void:
	var tilemap := MapLayer.main
	if tilemap == null:
		return

	_ui_canvas = CanvasLayer.new()
	_ui_canvas.layer = RenderLayers.STAGE_CHOICE
	add_child(_ui_canvas)

	_clump_polygons.clear()
	for value in _CHOICES:
		var choice: Dictionary = _CHOICES[value]
		var tint: Color = choice["tint"]
		var polys: Array[Polygon2D] = []
		for cell in choice["cells"]:
			var overlay: Polygon2D = tilemap.get_cell_overlay(cell)
			if overlay == null:
				continue
			overlay.color = tint
			overlay.modulate = Color(1, 1, 1, 0)
			overlay.z_index = RenderLayers.STAGE_CHOICE
			tilemap.add_child(overlay)
			polys.append(overlay)
		_clump_polygons[value] = polys

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_left = 648
	row.offset_right = -24
	row.offset_top = -300
	row.offset_bottom = -220
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	_ui_canvas.add_child(row)

	var prev_btn := Button.new()
	prev_btn.text = "◀"
	prev_btn.custom_minimum_size = Vector2(80, 56)
	_style_button(prev_btn, Color(1, 1, 1, 0.25))
	row.add_child(prev_btn)
	prev_btn.pressed.connect(func(): _cycle_choice(-1))

	_choose_btn = Button.new()
	_choose_btn.custom_minimum_size = Vector2(240, 56)
	row.add_child(_choose_btn)
	_choose_btn.pressed.connect(func(): _on_choice(_CHOICES.keys()[_current_choice_index]))

	var next_btn := Button.new()
	next_btn.text = "▶"
	next_btn.custom_minimum_size = Vector2(80, 56)
	_style_button(next_btn, Color(1, 1, 1, 0.25))
	row.add_child(next_btn)
	next_btn.pressed.connect(func(): _cycle_choice(1))

	_current_choice_index = 0
	_show_only(_CHOICES.keys()[_current_choice_index])


func _style_button(btn: Button, accent: Color) -> void:
	var make_sb := func(bg: Color, border: Color) -> StyleBoxFlat:
		var sb := StyleBoxFlat.new()
		sb.bg_color = bg
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(4)
		sb.border_color = border
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
		return sb
	var bg := Color(0.08, 0.10, 0.15, 0.92)
	var bg_hover := Color(0.14, 0.17, 0.24, 0.95)
	var bg_pressed := Color(0.05, 0.06, 0.10, 0.95)
	btn.add_theme_stylebox_override("normal", make_sb.call(bg, accent))
	btn.add_theme_stylebox_override("hover", make_sb.call(bg_hover, Color(accent.r, accent.g, accent.b, min(accent.a + 0.4, 1.0))))
	btn.add_theme_stylebox_override("pressed", make_sb.call(bg_pressed, accent))
	btn.add_theme_stylebox_override("focus", make_sb.call(bg, accent))
	btn.add_theme_color_override("font_color", Color(0.96, 0.96, 0.96))
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color(0.85, 0.85, 0.85))
	btn.add_theme_font_size_override("font_size", 22)


func _cycle_choice(delta: int) -> void:
	var keys: Array = _CHOICES.keys()
	_current_choice_index = (_current_choice_index + delta + keys.size()) % keys.size()
	_show_only(keys[_current_choice_index])


func _show_only(active_value) -> void:
	for value in _clump_polygons:
		var alpha: float = 1.0 if value == active_value else 0.0
		_fade_clump(_clump_polygons[value], alpha)
	var tint: Color = _CHOICES[active_value]["tint"]
	# Use tint as accent border (saturated, opaque), not as text color.
	var accent := Color(tint.r, tint.g, tint.b, 1.0)
	_choose_btn.text = "Choose %s" % GameState.LandLocation.keys()[active_value]
	_style_button(_choose_btn, accent)


func _on_choice(value: GameState.LandLocation) -> void:
	GameState.land_location = value
	var ts_chosen: float = Time.get_unix_time_from_system()
	var entry := Metrics.ChoiceEntry.new()
	entry.value = GameState.LandLocation.keys()[value]
	entry.ts_started = _ts_started
	entry.ts_chosen = ts_chosen
	entry.ts_duration = ts_chosen - _ts_started
	GameState.metrics.land_choice = entry
	Dialogue.dismiss()
	if _ui_canvas:
		_ui_canvas.queue_free()
		_ui_canvas = null
	_clear_clumps()

	var chosen: Dictionary = _CHOICES[value]
	var sign_cells: Array = chosen["signs"]
	var sign_set: Dictionary = {}
	for c in sign_cells:
		sign_set[c] = true

	for cell in sign_cells:
		MapLayer.main.set_cell_by_texture(cell, _CONSTRUCTION_SIGN)

	for cell in chosen["cells"]:
		if sign_set.has(cell):
			continue
		var delay: float = randf() * _CONSTRUCTION_MAX_DELAY
		get_tree().create_timer(delay).timeout.connect(
			MapLayer.main.set_cell_by_texture.bind(cell, _CONSTRUCTION_TILE), CONNECT_ONE_SHOT)

	var sign_replace_at: float = _CONSTRUCTION_MAX_DELAY + _SIGN_HOLD_DELAY
	for cell in sign_cells:
		get_tree().create_timer(sign_replace_at).timeout.connect(
			MapLayer.main.set_cell_by_texture.bind(cell, _CONSTRUCTION_TILE), CONNECT_ONE_SHOT)

	await get_tree().create_timer(sign_replace_at + _NEWSPAPER_DELAY).timeout

	var article: int = Newspaper.Article.FARMLAND
	match value:
		GameState.LandLocation.FIRST:
			article = Newspaper.Article.FARMLAND
		GameState.LandLocation.SECOND:
			article = Newspaper.Article.VILLAGE_TOO_CLOSE
		GameState.LandLocation.THIRD:
			article = Newspaper.Article.FOREST
		GameState.LandLocation.FOURTH:
			article = Newspaper.Article.FARMLAND

	Newspaper.on_close.connect(func():
		_show_continue_dialogue()
	, CONNECT_ONE_SHOT)
	Newspaper.show_article(article)


func _show_continue_dialogue() -> void:
	var opts := DialogueOptions.new()
	opts.dim = false
	opts.auto_close = false
	Dialogue.show_dialogue(
		_PORTRAIT,
		_SPEAKER,
		"Wow, that is terrible news. But we must move forward. Let us buy some hardware!",
		opts
	)
	Dialogue.on_typewriter_done.connect(_show_continue_button, CONNECT_ONE_SHOT)


func _show_continue_button() -> void:
	_ui_canvas = CanvasLayer.new()
	_ui_canvas.layer = RenderLayers.STAGE_CHOICE
	add_child(_ui_canvas)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_left = 648
	row.offset_right = -24
	row.offset_top = -300
	row.offset_bottom = -220
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 24)
	_ui_canvas.add_child(row)

	var btn := Button.new()
	btn.text = "To the Hardware Shop!"
	btn.custom_minimum_size = Vector2(250, 56)
	row.add_child(btn)

	btn.pressed.connect(func():
		finished.emit()
		btn.queue_free()
		Dialogue.dismiss()
		var lbl := Label.new()
		lbl.text = "Click on map to continue"
		lbl.custom_minimum_size = Vector2(500, 250)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0, 1.0))
		row.add_child(lbl)
	)

func _fade_clump(polys: Array, target_alpha: float) -> void:
	for p in polys:
		if not is_instance_valid(p):
			continue
		var prev: Tween = p.get_meta("_hover_tween", null) as Tween
		if prev and prev.is_valid():
			prev.kill()
		var t := create_tween()
		t.tween_property(p, "modulate:a", target_alpha, _HOVER_FADE_DURATION)
		p.set_meta("_hover_tween", t)


func _clear_clumps() -> void:
	for polys in _clump_polygons.values():
		for p in polys:
			if is_instance_valid(p):
				p.queue_free()
	_clump_polygons.clear()


func _stage_end() -> void:
	_clear_clumps()
	if _ui_canvas:
		_ui_canvas.queue_free()
		_ui_canvas = null
	if Dialogue.on_typewriter_done.is_connected(_show_choices):
		Dialogue.on_typewriter_done.disconnect(_show_choices)
	if Dialogue.on_typewriter_done.is_connected(_show_continue_button):
		Dialogue.on_typewriter_done.disconnect(_show_continue_button)
	Dialogue.dismiss()
	Newspaper.dismiss()
	finished.emit()
