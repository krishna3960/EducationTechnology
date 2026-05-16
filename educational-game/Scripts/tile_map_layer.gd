class_name MapLayer
extends TileMapLayer

const DEFAULT_CAMERA_CELL: Vector2i = Vector2i(3, 0)

static var _coord_labels: Array = []
static var main: TileMapLayer = null


func _ready() -> void:
	main = self
	var camera: Camera2D = get_parent().get_node_or_null("Camera2D") if get_parent() else null
	if camera:
		camera.position = map_to_local(DEFAULT_CAMERA_CELL)
		camera.reset_smoothing()
	if OS.is_debug_build():
		var section: VBoxContainer = Debug.add_section("Tilemap")
		Debug.add_checkbox("Show coords", false, _toggle_coord_labels, section)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := local_to_map(to_local(get_global_mouse_position()))
		print("Clicked tile:", cell)




# Shows labels for each tile displaying its coordinates.
func _toggle_coord_labels(enabled: bool) -> void:
	for lbl in _coord_labels:
		if is_instance_valid(lbl):
			lbl.queue_free()
	_coord_labels.clear()
	if not enabled or main == null:
		return
	for cell in main.get_used_cells():
		var lbl := Label.new()
		lbl.text = "%d,%d" % [cell.x, cell.y]
		lbl.add_theme_font_size_override("font_size", 32)
		lbl.add_theme_color_override("font_color", Color.YELLOW)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.size = Vector2(160, 48)
		lbl.position = main.map_to_local(cell) - lbl.size * 0.5
		lbl.z_index = 1000
		main.add_child(lbl)
		_coord_labels.append(lbl)

## Bit of a workaround. Given the 2D coordinate of a tile, returns a a Sprite2D instance which is layered precisely on top of the tile, with the same image as the tile.
func get_tile(cell: Vector2i) -> Sprite2D:
	var src := get_cell_source_id(cell)
	if src == -1:
		return null
	var atlas := tile_set.get_source(src) as TileSetAtlasSource
	if atlas == null:
		return null
	var atlas_coords := get_cell_atlas_coords(cell)
	var s := Sprite2D.new()
	s.texture = atlas.texture
	s.region_enabled = true
	s.region_rect = atlas.get_tile_texture_region(atlas_coords)
	s.position = map_to_local(cell)
	s.z_index = z_index + 1
	add_child(s)
	return s


## Replaces the tile at `cell` with the tile whose source texture matches `texture_path`.
func set_cell_by_texture(cell: Vector2i, texture_path: String) -> void:
	for i in tile_set.get_source_count():
		var source_id: int = tile_set.get_source_id(i)
		var source := tile_set.get_source(source_id) as TileSetAtlasSource
		if source and source.texture and source.texture.resource_path == texture_path:
			set_cell(cell, source_id, Vector2i.ZERO)
			return


## Returns a hexagon covering the hex base (the terrain part of the tile)
func get_cell_overlay(cell: Vector2i) -> Polygon2D:
	var size := Vector2(tile_set.tile_size)
	var hw: float = size.x * 0.5
	var hh: float = size.y * 0.5
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([
		Vector2(-hw * 0.5, -hh),
		Vector2( hw * 0.5, -hh),
		Vector2( hw, 0),
		Vector2( hw * 0.5, hh),
		Vector2(-hw * 0.5, hh),
		Vector2(-hw, 0),
	])
	p.position = map_to_local(cell)
	return p
