extends Stage

@export var _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant_v1.png")
@export var _INTRO_TEXT: String = "Congratulations you now have access to enough electricity to power your datacenter. However all this now creates a heating issue, we are going to need access to water to cool our server!"
@export var _OUTRO_TEXT: String = "Okay we have access to water now, but it is not sufficient to coold down all our servers, choose another tile to get access to more water !"

const _WATER_TINT: Color = Color(1.0, 1.0, 0.0, 0.6)
const _WATER_HOVER_TINT: Color = Color(1.0, 1.0, 0.4, 0.85)
const _HOVER_FADE_DURATION: float = 0.08
const _RIVER_TARGET_FAMILY: String = "river-1-"
const _PLACEHOLDER_TILE: String = "res://Assets/tiles/construction_land_tile.png"
const _NEWSPAPER_DELAY: float = 1.0
const _SWAP_DELAY_PER_TILE: float = 0.12

# The 6 clickable highlight tiles
const _WATER_CELLS: Array = [
	Vector2i(-2, 5), Vector2i(-5, 3), Vector2i(5, 4),
	Vector2i(9, 2), Vector2i(9, -2), Vector2i(-2, 1),
]

# River groups: each clickable tile maps to a river group index
const _CELL_TO_RIVER: Dictionary = {
	Vector2i(9, -2): 0,
	Vector2i(-2, 1): 0,
	Vector2i(-2, 5): 1,
	Vector2i(-5, 3): 1,
	Vector2i(5, 4): 2,
	Vector2i(9, 2): 2,
}

# The river tile cells for each group
const _RIVER_GROUPS: Array = [
	# River 0 — long northern river
	[
		Vector2i(-6, -2), Vector2i(-5, -2), Vector2i(-5, -1), Vector2i(-4, 0),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, -1), Vector2i(0, -1),
		Vector2i(1, -2), Vector2i(2, -2), Vector2i(2, -3), Vector2i(3, -4),
		Vector2i(4, -3), Vector2i(5, -4), Vector2i(6, -3), Vector2i(7, -4),
		Vector2i(8, -3), Vector2i(9, -3), Vector2i(10, -2), Vector2i(11, -3),
	],
	# River 1 — short western river
	[
		Vector2i(-6, 5), Vector2i(-5, 4), Vector2i(-4, 5),
		Vector2i(-3, 5), Vector2i(-2, 6), Vector2i(-2, 7), Vector2i(-2,8)
	],
	# River 2 — eastern river
	[
		Vector2i(6, 8), Vector2i(6, 7), Vector2i(5, 6), Vector2i(5, 5),
		Vector2i(6, 5), Vector2i(7, 4), Vector2i(8, 4), Vector2i(9, 3),
		Vector2i(10, 3), Vector2i(10, 2), Vector2i(11, 1),
	],
]

var _overlays: Array[Polygon2D] = []
var _overlay_to_cell: Dictionary = {}  # Polygon2D -> Vector2i
var _hovered: Polygon2D = null
var _selected_cell: Vector2i      # the tile chosen in the first round
var _first_river_index: int = -1  # river group chosen in the first round
var _second_round: bool = false

func _stage_start() -> void:
	_show_intro()

func _show_intro() -> void:
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = true
	Dialogue.on_close.connect(_on_intro_closed, CONNECT_ONE_SHOT)
	Dialogue.show_dialogue(_PORTRAIT, _INTRO_TEXT, opts)

func _on_intro_closed() -> void:
	_show_water_choices()

func _show_water_choices() -> void:
	var tilemap := MapLayer.main
	if tilemap == null:
		return

	for cell in _WATER_CELLS:
		var overlay: Polygon2D = tilemap.get_cell_overlay(cell)
		if overlay == null:
			continue
		overlay.color = _WATER_TINT
		overlay.z_index = RenderLayers.STAGE_CHOICE
		tilemap.add_child(overlay)
		_overlays.append(overlay)
		_overlay_to_cell[overlay] = cell

func _process(_delta: float) -> void:
	if _overlays.is_empty():
		return
	var tilemap := MapLayer.main
	if tilemap == null:
		return
	var mouse_pos: Vector2 = tilemap.get_global_mouse_position()
	var local_pos: Vector2 = tilemap.to_local(mouse_pos)

	var new_hovered: Polygon2D = null
	for overlay in _overlays:
		if not is_instance_valid(overlay):
			continue
		var relative := local_pos - overlay.position
		if Geometry2D.is_point_in_polygon(relative, overlay.polygon):
			new_hovered = overlay
			break

	if new_hovered != _hovered:
		if _hovered != null and is_instance_valid(_hovered):
			_tween_color(_hovered, _WATER_TINT)
		if new_hovered != null:
			_tween_color(new_hovered, _WATER_HOVER_TINT)
		_hovered = new_hovered

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if _hovered == null or not is_instance_valid(_hovered):
		return
	_on_tile_selected(_hovered)

func _on_tile_selected(overlay: Polygon2D) -> void:
	var cell: Vector2i = _overlay_to_cell[overlay]

	if _second_round:
		_on_second_choice(cell)
		return

	var river_index: int = _CELL_TO_RIVER[cell]
	EventLogger.record("water_choice", {
		"cell": "%d,%d" % [cell.x, cell.y],
		"river": river_index,
	})

	_selected_cell = cell
	_first_river_index = river_index

	# Replace the clicked tile with placeholder
	MapLayer.main.set_cell_by_texture(cell, _PLACEHOLDER_TILE)

	# Swap all tiles in the chosen river group to the river-1 family, left to right
	_hovered = null
	_clear_overlays()
	var total_duration: float = _animate_river_swap(_RIVER_GROUPS[river_index], _RIVER_TARGET_FAMILY)
	await get_tree().create_timer(total_duration).timeout
	_show_outro()

func _show_outro() -> void:
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = true
	Dialogue.on_close.connect(_on_outro_closed, CONNECT_ONE_SHOT)
	Dialogue.show_dialogue(_PORTRAIT, _OUTRO_TEXT, opts)

func _on_outro_closed() -> void:
	_second_round = true
	_show_remaining_choices()

func _show_remaining_choices() -> void:
	var tilemap := MapLayer.main
	if tilemap == null:
		return

	for cell in _WATER_CELLS:
		if cell == _selected_cell:
			continue
		var overlay: Polygon2D = tilemap.get_cell_overlay(cell)
		if overlay == null:
			continue
		overlay.color = _WATER_TINT
		overlay.z_index = RenderLayers.STAGE_CHOICE
		tilemap.add_child(overlay)
		_overlays.append(overlay)
		_overlay_to_cell[overlay] = cell

func _on_second_choice(cell: Vector2i) -> void:
	var river_index: int = _CELL_TO_RIVER[cell]
	EventLogger.record("water_choice_2", {
		"cell": "%d,%d" % [cell.x, cell.y],
		"river": river_index,
	})

	# Replace the clicked tile with placeholder
	MapLayer.main.set_cell_by_texture(cell, _PLACEHOLDER_TILE)

	# Same river as first choice -> river-2, different river -> river-1
	var target: String = "river-2-" if river_index == _first_river_index else "river-1-"

	_hovered = null
	_clear_overlays()
	var total_duration: float = _animate_river_swap(_RIVER_GROUPS[river_index], target)
	await get_tree().create_timer(total_duration + _NEWSPAPER_DELAY).timeout
	_show_newspaper()

func _show_newspaper() -> void:
	Newspaper.on_close.connect(func(): finished.emit(), CONNECT_ONE_SHOT)
	Newspaper.show_article(Newspaper.Article.WATER_CRISIS)

func _animate_river_swap(cells: Array, target_family: String) -> float:
	var sorted := cells.duplicate()
	sorted.sort_custom(func(a, b): return a.x < b.x)
	for i in sorted.size():
		var delay: float = i * _SWAP_DELAY_PER_TILE
		get_tree().create_timer(delay).timeout.connect(
			_swap_river_tile_to.bind(sorted[i], target_family), CONNECT_ONE_SHOT)
	return sorted.size() * _SWAP_DELAY_PER_TILE

func _swap_river_tile(cell: Vector2i) -> void:
	_swap_river_tile_to(cell, _RIVER_TARGET_FAMILY)

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

func _tween_color(overlay: Polygon2D, target: Color) -> void:
	var prev: Tween = overlay.get_meta("_hover_tween", null) as Tween
	if prev and prev.is_valid():
		prev.kill()
	var t := create_tween()
	t.tween_property(overlay, "color", target, _HOVER_FADE_DURATION)
	overlay.set_meta("_hover_tween", t)

func _clear_overlays() -> void:
	for o in _overlays:
		if is_instance_valid(o):
			o.queue_free()
	_overlays.clear()
	_overlay_to_cell.clear()
	_hovered = null

func _stage_end() -> void:
	_clear_overlays()
	Dialogue.dismiss()
	Newspaper.dismiss()
