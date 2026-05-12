extends Stage

@export var _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant_v1.png")
@export const _SPEAKER: String = "Prompto"
@export var _INTRO_TEXT: String = "Ah thats a shame about the news....but your new hardware looks so good! Now we just need to power them up with electrcity. Where do you want to get electricity from?"

const _EXPANSION_TILE: String = "res://Assets/tiles/tiles_tree_grass_sheeps/tiles_grass_v6.png"
const _FACTORY_TILE: String = "res://Assets/tiles/tiles-aiCenter/tile-aiCenter-expansion-v6-lights-off.png"
const _FACTORY_LIT_TILE: String = "res://Assets/tiles/tiles-aiCenter/tile-aiCenter-expansion-v6.png"
const _ELECTRIC_POLE_TILE: String = "res://Assets/tiles/tile_electric_pole_aiCenter.png"

const _CHOICES: Dictionary = {
	GameState.LandLocation.FIRST: {
		"cells": [Vector2i(3, 2), Vector2i(2, 0), Vector2i(4, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 2), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3), Vector2i(2, 4), Vector2i(2, 3), Vector2i(1, 4), Vector2i(0, 4), Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1), Vector2i(1, 2), Vector2i(1, 3)],
		"factory": [Vector2i(3, 1), Vector2i(4, 1), Vector2i(2, 1), Vector2i(3, 2), Vector2i(2, 2)],
	},
	GameState.LandLocation.SECOND: {
		"cells": [Vector2i(3, 2), Vector2i(3, -1), Vector2i(3, -2), Vector2i(3, 1), Vector2i(4, 2), Vector2i(5, 1), Vector2i(2, 2), Vector2i(1, 1), Vector2i(2, -1), Vector2i(1, -1), Vector2i(4, -1), Vector2i(5, -1), Vector2i(5, 0), Vector2i(4, 0), Vector2i(4, 1), Vector2i(2, 0), Vector2i(2, 1), Vector2i(1, 0)],
		"factory": [Vector2i(3, 1), Vector2i(4, 1), Vector2i(3, 0), Vector2i(4, 0), Vector2i(3, -1)],
	},
	GameState.LandLocation.THIRD: {
		"cells": [Vector2i(3, 2), Vector2i(2, 0), Vector2i(1, -1), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(-2, 2), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 1), Vector2i(2, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(0, 2), Vector2i(-1, 2)],
		"factory": [Vector2i(1, 1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, 0), Vector2i(1, 2)],
	},
	GameState.LandLocation.FOURTH: {
		"cells": [Vector2i(3, 2), Vector2i(2, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 4), Vector2i(5, 3), Vector2i(6, 3), Vector2i(6, 2), Vector2i(5, 1), Vector2i(4, 1), Vector2i(3, 1), Vector2i(2, 2), Vector2i(4, 2), Vector2i(4, 3), Vector2i(5, 2)],
		"factory": [Vector2i(3, 1), Vector2i(4, 1), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 1)],
	},
}

const _ELECTRICITY_CHOICES: Dictionary = {
	"far": {
		"tint": Color(0.0, 1.0, 0.0, 0.518),
		"cells": [Vector2i(-5, 2)],
	},
	"close": {
		"tint": Color(1.4, 0.0, 0.0, 0.624),
		"cells": [Vector2i(8, 0)],
	},
}

const _HOVER_FADE_DURATION: float = 0.08

var _clump_polygons: Dictionary = {}
var _ui_canvas: CanvasLayer

func _stage_start() -> void:
	var camera := get_viewport().get_camera_2d()
	camera.zoom = Vector2(0.2, 0.2)
	camera.position = Vector2(500, 0)

	var chosen = _CHOICES[GameState.land_location]
	for cell in chosen["cells"]:
		MapLayer.main.set_cell_by_texture(cell, _EXPANSION_TILE)
	for cell in chosen["factory"]:
		MapLayer.main.set_cell_by_texture(cell, _FACTORY_TILE)

	Newspaper.on_close.connect(_show_intro_dialogue, CONNECT_ONE_SHOT)
	Newspaper.show_article(Newspaper.Article.PRICES_LAPTOPS)


func _show_intro_dialogue() -> void:
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
	for key in _ELECTRICITY_CHOICES:
		var choice: Dictionary = _ELECTRICITY_CHOICES[key]
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
		_clump_polygons[key] = polys

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_left = 648
	row.offset_right = -24
	row.offset_top = -300
	row.offset_bottom = -220
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 24)
	_ui_canvas.add_child(row)

	for key in _ELECTRICITY_CHOICES:
		var tint: Color = _ELECTRICITY_CHOICES[key]["tint"]
		var polys: Array = _clump_polygons[key]

		var btn := Button.new()
		btn.text = "Further from village" if key == "far" else "Close to village"
		btn.custom_minimum_size = Vector2(160, 56)
		btn.add_theme_color_override("font_color", Color(tint.r, tint.g, tint.b, 1.0))
		row.add_child(btn)

		btn.mouse_entered.connect(func(): _fade_clump(polys, 1.0))
		btn.mouse_exited.connect(func(): _fade_clump(polys, 0.0))
		btn.pressed.connect(func(): _on_choice(key))

func _on_choice(key: String) -> void:
	GameState.electricity_choice = key
	Dialogue.dismiss()
	if _ui_canvas:
		_ui_canvas.queue_free()
		_ui_canvas = null
	_clear_clumps()

	for cell in _ELECTRICITY_CHOICES[key]["cells"]:
		MapLayer.main.set_cell_by_texture(cell, _ELECTRIC_POLE_TILE)

	await get_tree().create_timer(1.0).timeout

	var article: int = Newspaper.Article.FARMLAND
	match key:
		"far":
			article = Newspaper.Article.SCIENTIST
		"close":
			article = Newspaper.Article.WINTER

	Newspaper.on_close.connect(func():
		var chosen = _CHOICES[GameState.land_location]
		for cell in chosen["factory"]:
			MapLayer.main.set_cell_by_texture(cell, _FACTORY_LIT_TILE)

		await get_tree().create_timer(1.0).timeout
		_show_prompt_dialogue()
	, CONNECT_ONE_SHOT)
	Newspaper.show_article(article)

func _show_prompt_dialogue() -> void:
	var opts := DialogueOptions.new()
	opts.dim = false
	opts.auto_close = false
	Dialogue.show_dialogue(
		_PORTRAIT,
		_SPEAKER,
		"The news hurts me, but seeing our datacenter light up makes me happy!...However we now have a new problem. We are getting a lot of wasteful prompts. Should we educate our users on how to prompt better?",
		opts
	)
	Dialogue.on_typewriter_done.connect(_show_prompt_choice_button, CONNECT_ONE_SHOT)

func _show_prompt_choice_button() -> void:
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
	btn.text = "Yes"
	btn.custom_minimum_size = Vector2(160, 56)
	row.add_child(btn)

	btn.pressed.connect(func():
		Dialogue.dismiss()
		if _ui_canvas:
			_ui_canvas.queue_free()
			_ui_canvas = null
		_stage_end()
	)

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
	if Dialogue.on_typewriter_done.is_connected(_show_prompt_choice_button):
		Dialogue.on_typewriter_done.disconnect(_show_prompt_choice_button)
	Dialogue.dismiss()
	Newspaper.dismiss()
	finished.emit()
