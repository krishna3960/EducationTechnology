extends TileMapLayer

# Shared across all TileMapLayer instances using this script so we declare some shared state statically. Wacky
static var _coord_labels: Array = []
static var _debug_registered: bool = false
static var _input_handler: TileMapLayer = null


func _ready() -> void:
	if not _input_handler:
		_input_handler = self

	if OS.is_debug_build() and not _debug_registered:
		_debug_registered = true
		var section: VBoxContainer = Debug.add_section("Tilemap")
		Debug.add_checkbox("Show coords", false, _toggle_coord_labels, section)


func _unhandled_input(event: InputEvent) -> void:
	if self != _input_handler:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := local_to_map(to_local(get_global_mouse_position()))
		print("Clicked tile:", cell)


# Shows labels for each tile displaying its coordinates.
func _toggle_coord_labels(enabled: bool) -> void:
	# Remove current labels if any
	for lbl in _coord_labels:
		if is_instance_valid(lbl):
			lbl.queue_free()
	_coord_labels.clear()
	if not enabled or _input_handler == null:
		return
	var seen := {}
	for child in _input_handler.get_parent().get_children():
		if not (child is TileMapLayer):
			continue
		for cell in child.get_used_cells():
			if seen.has(cell):
				continue
			seen[cell] = true
			var lbl := Label.new()
			lbl.text = "%d,%d" % [cell.x, cell.y]
			lbl.position = child.map_to_local(cell)
			lbl.add_theme_font_size_override("font_size", 32)
			lbl.add_theme_color_override("font_color", Color.YELLOW)
			lbl.z_index = 1000
			child.add_child(lbl)
			_coord_labels.append(lbl)

@onready var tilemap = $"../MiddleLayer"
func change_tile(cell: Vector2i, atlas_coords: Vector2i, source_id: int = 0):
	tilemap.set_cell(cell, source_id, atlas_coords)


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


## Returns a hexagon covering exactly the tile at the given coordinates. Useful for highlighting or similar
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
	p.position = to_global(map_to_local(cell))
	return p
