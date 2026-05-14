extends Stage

@export var _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant_v1.png")
@export var _SPEAKER: String = "Prompto"
@export var _INTRO_TEXT: String = "Congratulations your education was a success! You have reduced token usage and we now have enough compute and electricity to handle all the incoming promps. However all this now creates a heating issue, we are going to need access to water to cool our server!"
@export var _OUTRO_TEXT: String = "Okay we have access to water now, but it is not sufficient to cool down all our servers, choose another river to get access to more water!"

const _WATER_TINT: Color = Color(1.0, 1.0, 0.0, 0.706)
const _HOVER_FADE_DURATION: float = 0.08
const _RIVER_TARGET_FAMILY: String = "river-1-"
const _WATER_PUMP_PREFIX: String = "water-pump-"
const _NEWSPAPER_DELAY: float = 1.0
const _SWAP_DELAY_PER_TILE: float = 0.12

# Each river choice: label, highlight cells on map, placeholder tiles (two per river),
# and the full river cells to swap
const _WATER_CHOICES: Dictionary = {
	"north": {
		"label": "North River",
		"tint": Color(1.0, 1.0, 0.0, 0.706),
		"river_cells": [
			Vector2i(-6, -2), Vector2i(-5, -2), Vector2i(-5, -1), Vector2i(-4, 0),
			Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, -1), Vector2i(0, -1),
			Vector2i(1, -2), Vector2i(2, -2), Vector2i(2, -3), Vector2i(3, -4),
			Vector2i(4, -3), Vector2i(5, -4), Vector2i(6, -3), Vector2i(7, -4),
			Vector2i(8, -3), Vector2i(9, -3), Vector2i(10, -2), Vector2i(11, -3),
		],
	},
	"west": {
		"label": "West River",
		"tint": Color(1.0, 1.0, 0.0, 0.706),
		"river_cells": [
			Vector2i(-6, 5), Vector2i(-5, 4), Vector2i(-4, 5),
			Vector2i(-3, 5), Vector2i(-2, 6), Vector2i(-2, 7), Vector2i(-2, 8),
		],
	},
	"east": {
		"label": "East River",
		"tint": Color(1.0, 1.0, 0.0, 0.706),
		"river_cells": [
			Vector2i(6, 8), Vector2i(6, 7), Vector2i(5, 6), Vector2i(5, 5),
			Vector2i(6, 5), Vector2i(7, 4), Vector2i(8, 4), Vector2i(9, 3),
			Vector2i(10, 3), Vector2i(10, 2), Vector2i(11, 1),
		],
	},
}

# Pump cells resolved at runtime — maps key -> [cell1, cell2]
var _pump_cells: Dictionary = {}

var _clump_polygons: Dictionary = {}  # key -> Array[Polygon2D]
var _ui_canvas: CanvasLayer
var _current_choice_index: int = 0
var _choose_btn: Button = null
var _first_choice_key: String = ""
var _second_round: bool = false
var _ts_choice_started: float = 0.0

func _stage_start() -> void:
	_resolve_pump_cells()
	_show_intro()

func _resolve_pump_cells() -> void:
	var tilemap := MapLayer.main
	if tilemap == null:
		return
	for key in _WATER_CHOICES:
		var first_cell: Vector2i = Vector2i.ZERO
		var second_cell: Vector2i = Vector2i.ZERO
		var found_first := false
		var found_second := false
		for cell in _WATER_CHOICES[key]["river_cells"]:
			if found_first and found_second:
				break
			var shape := _get_river_shape(cell)
			if shape.is_empty():
				continue
			if not found_first and _tileset_has_pump(shape, 1):
				first_cell = cell
				found_first = true
			elif not found_second and _tileset_has_pump(shape, 2):
				second_cell = cell
				found_second = true
		var cells: Array = []
		if found_first:
			cells.append(first_cell)
		if found_second:
			cells.append(second_cell)
		_pump_cells[key] = cells

func _get_river_shape(cell: Vector2i) -> String:
	var tilemap := MapLayer.main
	var src_id := tilemap.get_cell_source_id(cell)
	if src_id == -1:
		return ""
	var atlas := tilemap.tile_set.get_source(src_id) as TileSetAtlasSource
	if atlas == null or atlas.texture == null:
		return ""
	var file_name: String = atlas.texture.resource_path.get_file()
	for prefix in ["river-0-", "river-1-", "river-2-"]:
		if file_name.begins_with(prefix):
			return file_name.substr(prefix.length())
	return ""

func _tileset_has_pump(shape: String, version: int) -> bool:
	var path: String = "res://Assets/tiles/water-pump-%d-%s" % [version, shape]
	return _tileset_has_texture(path)

func _tileset_has_texture(path: String) -> bool:
	var tilemap := MapLayer.main
	for i in tilemap.tile_set.get_source_count():
		var source_id: int = tilemap.tile_set.get_source_id(i)
		var source := tilemap.tile_set.get_source(source_id) as TileSetAtlasSource
		if source and source.texture and source.texture.resource_path == path:
			return true
	return false

func _show_intro() -> void:
	var opts := DialogueOptions.new()
	opts.dim = false
	opts.auto_close = false
	Dialogue.on_typewriter_done.connect(_show_choices, CONNECT_ONE_SHOT)
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _INTRO_TEXT, opts)

func _show_choices() -> void:
	var tilemap := MapLayer.main
	if tilemap == null:
		return

	_ts_choice_started = Time.get_unix_time_from_system()
	_ui_canvas = CanvasLayer.new()
	_ui_canvas.layer = RenderLayers.STAGE_CHOICE
	add_child(_ui_canvas)

	_clump_polygons.clear()
	var keys: Array = _get_available_keys()
	for key in keys:
		var choice: Dictionary = _WATER_CHOICES[key]
		var tint: Color = choice["tint"]
		# Show the second tile if this river was already picked in round 1
		var pump_list: Array = _pump_cells.get(key, [])
		if pump_list.is_empty():
			continue
		var cell_index: int = 1 if (_second_round and key == _first_choice_key and pump_list.size() > 1) else 0
		var cell: Vector2i = pump_list[cell_index]
		var polys: Array[Polygon2D] = []
		var overlay: Polygon2D = tilemap.get_cell_overlay(cell)
		if overlay != null:
			overlay.color = tint
			overlay.modulate = Color(1, 1, 1, 0)
			overlay.z_index = RenderLayers.STAGE_CHOICE
			tilemap.add_child(overlay)
			polys.append(overlay)
		_clump_polygons[key] = polys

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
	_choose_btn.custom_minimum_size = Vector2(280, 56)
	row.add_child(_choose_btn)
	_choose_btn.pressed.connect(func(): _on_choice(keys[_current_choice_index]))

	var next_btn := Button.new()
	next_btn.text = "▶"
	next_btn.custom_minimum_size = Vector2(80, 56)
	_style_button(next_btn, Color(1, 1, 1, 0.25))
	row.add_child(next_btn)
	next_btn.pressed.connect(func(): _cycle_choice(1))

	_current_choice_index = 0
	_show_only(keys[_current_choice_index])

func _get_available_keys() -> Array:
	if not _second_round:
		return _WATER_CHOICES.keys()
	# All choices remain available in round 2
	return _WATER_CHOICES.keys()

func _cycle_choice(delta: int) -> void:
	var keys: Array = _get_available_keys()
	_current_choice_index = (_current_choice_index + delta + keys.size()) % keys.size()
	_show_only(keys[_current_choice_index])

func _show_only(active_key) -> void:
	for key in _clump_polygons:
		var alpha: float = 1.0 if key == active_key else 0.0
		_fade_clump(_clump_polygons[key], alpha)
	var tint: Color = _WATER_CHOICES[active_key]["tint"]
	var accent := Color(tint.r, tint.g, tint.b, 1.0)
	_choose_btn.text = "Choose %s" % _WATER_CHOICES[active_key]["label"]
	_style_button(_choose_btn, accent)

func _on_choice(key: String) -> void:
	var ts_chosen: float = Time.get_unix_time_from_system()
	var entry := Metrics.ChoiceEntry.new()
	entry.value = key
	entry.ts_started = _ts_choice_started
	entry.ts_chosen = ts_chosen
	entry.ts_duration = ts_chosen - _ts_choice_started
	GameState.metrics.water_choices.append(entry)

	Dialogue.dismiss()
	if _ui_canvas:
		_ui_canvas.queue_free()
		_ui_canvas = null
	_clear_clumps()

	var choice: Dictionary = _WATER_CHOICES[key]
	var same_as_first: bool = key == _first_choice_key

	# Replace the chosen river tile with a water-pump tile (same shape)
	var pump_list: Array = _pump_cells.get(key, [])
	var pump_index: int = 1 if (same_as_first and pump_list.size() > 1) else 0
	var pump_version: int = 2 if same_as_first else 1
	var pump_cell: Vector2i = pump_list[pump_index]
	_replace_with_pump(pump_cell, pump_version)

	# Collect all pump cells to exclude from the river swap
	var exclude: Dictionary = {pump_cell: true}
	if same_as_first and pump_list.size() > 1:
		exclude[pump_list[0]] = true

	# Determine target river family
	var target_family: String
	if not _second_round:
		target_family = "river-1-"
	elif same_as_first:
		target_family = "river-2-"
	else:
		target_family = "river-1-"

	var total_duration: float = _animate_river_swap(choice["river_cells"], target_family, exclude)
	await get_tree().create_timer(total_duration).timeout

	if not _second_round:
		_first_choice_key = key
		_second_round = true
		_show_outro()
	else:
		await get_tree().create_timer(_NEWSPAPER_DELAY).timeout
		_show_newspaper()

func _show_outro() -> void:
	var opts := DialogueOptions.new()
	opts.dim = false
	opts.auto_close = false
	Dialogue.on_typewriter_done.connect(_show_choices, CONNECT_ONE_SHOT)
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, _OUTRO_TEXT, opts)

func _show_newspaper() -> void:
	Newspaper.on_close.connect(func(): finished.emit(), CONNECT_ONE_SHOT)
	Newspaper.show_article(Newspaper.Article.WATER_CRISIS)

func _animate_river_swap(cells: Array, target_family: String, exclude: Dictionary = {}) -> float:
	var sorted := cells.duplicate()
	sorted.sort_custom(func(a, b): return a.x < b.x)
	var idx: int = 0
	for i in sorted.size():
		if exclude.has(sorted[i]):
			continue
		var delay: float = idx * _SWAP_DELAY_PER_TILE
		get_tree().create_timer(delay).timeout.connect(
			_swap_river_tile_to.bind(sorted[i], target_family), CONNECT_ONE_SHOT)
		idx += 1
	return idx * _SWAP_DELAY_PER_TILE

func _replace_with_pump(cell: Vector2i, pump_version: int) -> void:
	var tilemap := MapLayer.main
	var src_id := tilemap.get_cell_source_id(cell)
	if src_id == -1:
		return
	var atlas := tilemap.tile_set.get_source(src_id) as TileSetAtlasSource
	if atlas == null or atlas.texture == null:
		return
	var current_path: String = atlas.texture.resource_path
	var file_name: String = current_path.get_file()
	# river-0-diagL-400x484.png -> water-pump-1-diagL-400x484.png
	var new_name: String = file_name
	for prefix in ["river-0-", "river-1-", "river-2-"]:
		if file_name.begins_with(prefix):
			var shape: String = file_name.substr(prefix.length())
			new_name = "water-pump-%d-%s" % [pump_version, shape]
			break
	if new_name == file_name:
		return
	var new_path: String = current_path.get_base_dir() + "/" + new_name
	tilemap.set_cell_by_texture(cell, new_path)

func _swap_river_tile_to(cell: Vector2i, target_family: String) -> void:
	var tilemap := MapLayer.main
	var src_id := tilemap.get_cell_source_id(cell)
	if src_id == -1:
		return
	var atlas := tilemap.tile_set.get_source(src_id) as TileSetAtlasSource
	if atlas == null or atlas.texture == null:
		return
	var current_path: String = atlas.texture.resource_path
	var file_name: String = current_path.get_file()
	var new_name: String = file_name
	for prefix in ["river-0-", "river-1-", "river-2-"]:
		if file_name.begins_with(prefix):
			new_name = target_family + file_name.substr(prefix.length())
			break
	if new_name == file_name:
		return
	var new_path: String = current_path.get_base_dir() + "/" + new_name
	tilemap.set_cell_by_texture(cell, new_path)

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

func _fade_clump(polys: Array, target_alpha: float) -> void:
	for p in polys:
		if not is_instance_valid(p):
			continue
		var prev = p.get_meta("_hover_tween", null)
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
	Dialogue.dismiss()
	Newspaper.dismiss()
