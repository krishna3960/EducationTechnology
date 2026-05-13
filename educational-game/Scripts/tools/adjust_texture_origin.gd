@tool
extends EditorScript

# Anchors every tile's texture so its bottom half (the hex art) sits on the cell

const _TEXTURE_ORIGIN: Vector2i = Vector2i(0, 121)


func _run() -> void:
	var scene := EditorInterface.get_edited_scene_root()
	if scene == null:
		push_error("No scene open. Open tilemap.tscn first.")
		return

	var tile_sets: Dictionary = {}
	_collect(scene, tile_sets)

	if tile_sets.is_empty():
		push_warning("No TileSet found in the open scene.")
		return

	var updated := 0
	for ts in tile_sets:
		updated += _adjust_tile_set(ts)

	print("Updated texture_origin on %d tile(s) to %s." % [updated, _TEXTURE_ORIGIN])
	print("Save the scene to persist.")


func _collect(node: Node, tile_sets: Dictionary) -> void:
	if node is TileMapLayer and node.tile_set:
		tile_sets[node.tile_set] = true
	for child in node.get_children():
		_collect(child, tile_sets)


func _adjust_tile_set(tile_set: TileSet) -> int:
	var count := 0
	for i in tile_set.get_source_count():
		var src_id: int = tile_set.get_source_id(i)
		var src := tile_set.get_source(src_id) as TileSetAtlasSource
		if src == null:
			continue
		for j in src.get_tiles_count():
			var coords: Vector2i = src.get_tile_id(j)
			var alt_count: int = src.get_alternative_tiles_count(coords)
			for k in alt_count:
				var alt: int = src.get_alternative_tile_id(coords, k)
				var data: TileData = src.get_tile_data(coords, alt)
				if data:
					data.texture_origin = _TEXTURE_ORIGIN
					count += 1
	return count
