extends Stage

const _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant_v1.png")
const _INTRO_TEXT: String = "We need to start by buying some land for the datacenter. Where should we build it?"

const _CHOICES: Array = [
	{
		"cells": [Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 2), Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 2), Vector2i(3, 3), Vector2i(2, 4), Vector2i(2, 3), Vector2i(1, 4), Vector2i(0, 4), Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1), Vector2i(1, 2), Vector2i(1, 3)],
		"value": GameState.LandLocation.FIRST,
		"tint":  Color(0.0, 1.0, 0.0, 0.518),
	},
	{
		"cells": [Vector2i(3, 0), Vector2i(3, -1), Vector2i(3, -2), Vector2i(3, 1), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 1), Vector2i(2, 2), Vector2i(1, 1), Vector2i(2, -1), Vector2i(1, -1), Vector2i(4, -1), Vector2i(5, -1), Vector2i(5, 0), Vector2i(4, 0), Vector2i(4, 1), Vector2i(2, 0), Vector2i(2, 1), Vector2i(1, 0)],
		"value": GameState.LandLocation.SECOND,
		"tint":  Color(1.4, 0.0, 0.0, 0.624),
	},
	{
		"cells": [Vector2i(2, 0), Vector2i(1, -1), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(-2, 2), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 1), Vector2i(3, 0), Vector2i(2, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(0, 2), Vector2i(-1, 2)],
		"value": GameState.LandLocation.THIRD,
		"tint":  Color(0.0, 0.0, 1.4, 0.627),
	},
	{
		"cells": [Vector2i(2, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 4), Vector2i(5, 3), Vector2i(6, 3), Vector2i(6, 2), Vector2i(5, 1), Vector2i(4, 1), Vector2i(3, 0), Vector2i(3, 1), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(4, 3), Vector2i(5, 2)],
		"value": GameState.LandLocation.FOURTH,
		"tint":  Color(0.748, 0.068, 0.85, 0.627),
	},
]

const _HOVER_FADE_DURATION: float = 0.08

var _clumps_canvas: CanvasLayer       # world-space, holds the clump polygons
var _ui_canvas: CanvasLayer    # screen-space, holds the choice buttons


func _stage_start() -> void:
	Dialogue.on_typewriter_done.connect(_show_choices, CONNECT_ONE_SHOT)
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = false
	Dialogue.show_dialogue(_PORTRAIT, _INTRO_TEXT, opts)


func _show_choices() -> void:
	var tilemap := _find_tilemap()
	if tilemap == null:
		push_error("LandChoiceStage: no TileMapLayer found in scene")
		return

	_clumps_canvas = CanvasLayer.new()
	_clumps_canvas.layer = RenderLayers.STAGE_CHOICE
	_clumps_canvas.follow_viewport_enabled = true
	add_child(_clumps_canvas)

	_ui_canvas = CanvasLayer.new()
	_ui_canvas.layer = RenderLayers.STAGE_CHOICE
	add_child(_ui_canvas)

	# Build the clumps
	var clumps: Array = []
	for choice in _CHOICES:
		var clump := Node2D.new()
		_clumps_canvas.add_child(clump)
		# For tile in the clump we get an overlay of the tile
		for cell in choice["cells"]:
			var overlay: Polygon2D = tilemap.get_cell_overlay(cell)
			if overlay:
				clump.add_child(overlay)
		var tint: Color = choice["tint"]
		clump.modulate = Color(tint.r, tint.g, tint.b, 0.0)
		clumps.append(clump)

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
	for i in _CHOICES.size():
		var choice = _CHOICES[i]
		var clump: Node2D = clumps[i]
		var value: GameState.LandLocation = choice["value"]
		var tint: Color = choice["tint"]
		var visible_color := tint

		var btn := Button.new()
		btn.text = GameState.LandLocation.keys()[value]
		btn.custom_minimum_size = Vector2(160, 56)
		btn.add_theme_color_override("font_color", Color(tint.r, tint.g, tint.b, 1.0))
		row.add_child(btn)

		btn.mouse_entered.connect(func(): _fade_modulate(clump, visible_color))
		btn.mouse_exited.connect(func(): _fade_modulate(clump, Color(0,0,0, 0.0)))
		btn.pressed.connect(func(): _on_choice(value))


func _on_choice(value: GameState.LandLocation) -> void:
	GameState.land_location = value
	EventLogger.record("land_choice", {"value": GameState.LandLocation.keys()[value]})
	Dialogue.dismiss()
	if _clumps_canvas:
		_clumps_canvas.queue_free()
		_clumps_canvas = null
	if _ui_canvas:
		_ui_canvas.queue_free()
		_ui_canvas = null
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

# Very naive way to find the tilemap, we traverse the tree recursively.
func _find_tilemap() -> TileMapLayer:
	return get_tree().root.find_child("TileMapLayer", true, false) as TileMapLayer


# Fades a node's hue to the target color.
func _fade_modulate(node: CanvasItem, target: Color) -> void:
	if not is_instance_valid(node):
		return
	var prev: Tween = node.get_meta("_hover_tween", null) as Tween
	if prev and prev.is_valid():
		prev.kill()
	var t := create_tween()
	t.tween_property(node, "modulate", target, _HOVER_FADE_DURATION)
	node.set_meta("_hover_tween", t)


func _stage_end() -> void:
	if _clumps_canvas:
		_clumps_canvas.queue_free()
		_clumps_canvas = null
	if _ui_canvas:
		_ui_canvas.queue_free()
		_ui_canvas = null
	if Dialogue.on_typewriter_done.is_connected(_show_choices):
		Dialogue.on_typewriter_done.disconnect(_show_choices)
	Dialogue.dismiss()
	Newspaper.dismiss()
