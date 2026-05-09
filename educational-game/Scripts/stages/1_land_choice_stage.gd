extends Stage

@export var _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant_v1.png")
@export var _INTRO_TEXT: String = "We need to start by buying some land for the datacenter. Where should we build it?"

const _CHOICES: Dictionary = {
	GameState.LandLocation.FIRST: {
		"tint": Color(0.0, 1.0, 0.0, 0.518),
		"cells": [Vector2i(3, 2), Vector2i(2, 0), Vector2i(4, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 2), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3), Vector2i(2, 4), Vector2i(2, 3), Vector2i(1, 4), Vector2i(0, 4), Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1), Vector2i(1, 2), Vector2i(1, 3)],
	},
	GameState.LandLocation.SECOND: {
		"tint": Color(1.4, 0.0, 0.0, 0.624),
		"cells": [Vector2i(3, 2), Vector2i(3, -1), Vector2i(3, -2), Vector2i(3, 1), Vector2i(4, 2), Vector2i(5, 1), Vector2i(2, 2), Vector2i(1, 1), Vector2i(2, -1), Vector2i(1, -1), Vector2i(4, -1), Vector2i(5, -1), Vector2i(5, 0), Vector2i(4, 0), Vector2i(4, 1), Vector2i(2, 0), Vector2i(2, 1), Vector2i(1, 0)],
	},
	GameState.LandLocation.THIRD: {
		"tint": Color(0.0, 0.0, 1.4, 0.627),
		"cells": [Vector2i(3, 2), Vector2i(2, 0), Vector2i(1, -1), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(-2, 2), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 1), Vector2i(2, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(0, 2), Vector2i(-1, 2)],
	},
	GameState.LandLocation.FOURTH: {
		"tint": Color(0.748, 0.068, 0.85, 0.627),
		"cells": [Vector2i(3, 2), Vector2i(2, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 4), Vector2i(5, 3), Vector2i(6, 3), Vector2i(6, 2), Vector2i(5, 1), Vector2i(4, 1), Vector2i(3, 1), Vector2i(2, 2), Vector2i(4, 2), Vector2i(4, 3), Vector2i(5, 2)],
	},
}

const _HOVER_FADE_DURATION: float = 0.08

const _CONSTRUCTION_TILE: String = "res://Assets/tiles/construction_land_tile.png"
const _CONSTRUCTION_SIGN: String = "res://Assets/tiles/under_construction.png"
const _NEWSPAPER_DELAY: float = 1.0

var _clump_polygons: Dictionary = {}  # LandLocation -> Array[Polygon2D]
var _ui_canvas: CanvasLayer      # screen-space, holds the choice buttons


func _stage_start() -> void:
	Dialogue.on_typewriter_done.connect(_show_choices, CONNECT_ONE_SHOT)
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = false
	Dialogue.show_dialogue(_PORTRAIT, _INTRO_TEXT, opts)


func _show_choices() -> void:
	var tilemap := MapLayer.main
	if tilemap == null:
		return

	_ui_canvas = CanvasLayer.new()
	_ui_canvas.layer = RenderLayers.STAGE_CHOICE
	add_child(_ui_canvas)

	# Build the clumps
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

	# Button row sits just above the dialogue bubble
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_left = 648
	row.offset_right = -24
	row.offset_top = -300
	row.offset_bottom = -220
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 24)
	_ui_canvas.add_child(row)

	# Logic for each choice button
	for value in _CHOICES:
		var tint: Color = _CHOICES[value]["tint"]
		var polys: Array = _clump_polygons[value]

		var btn := Button.new()
		btn.text = GameState.LandLocation.keys()[value]
		btn.custom_minimum_size = Vector2(160, 56)
		btn.add_theme_color_override("font_color", Color(tint.r, tint.g, tint.b, 1.0))
		row.add_child(btn)

		btn.mouse_entered.connect(func(): _fade_clump(polys, 1.0))
		btn.mouse_exited.connect(func(): _fade_clump(polys, 0.0))
		btn.pressed.connect(func(): _on_choice(value))


func _on_choice(value: GameState.LandLocation) -> void:
	GameState.land_location = value
	EventLogger.record("land_choice", {"value": GameState.LandLocation.keys()[value]})
	Dialogue.dismiss()
	if _ui_canvas:
		_ui_canvas.queue_free()
		_ui_canvas = null
	_clear_clumps()

	# Set the chosen land to be the construction site
	var chosen: Dictionary = _CHOICES[value]
	for cell in chosen.get("cells", []):
		MapLayer.main.set_cell_by_texture(cell, _CONSTRUCTION_TILE)
	for cell in chosen.get("signs", []):
		MapLayer.main.set_cell_by_texture(cell, _CONSTRUCTION_SIGN)

	await get_tree().create_timer(_NEWSPAPER_DELAY).timeout

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
	Newspaper.on_close.connect(func(): finished.emit(), CONNECT_ONE_SHOT)
	Newspaper.show_article(article)


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
	Dialogue.dismiss()
	Newspaper.dismiss()
