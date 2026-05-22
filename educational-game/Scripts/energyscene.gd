extends Stage

const _SFX_CYCLE: AudioStream = preload("res://Assets/Music/Just A 1 Second Woosh Sound.mp3")
const _SFX_ELECTRIC: AudioStream = preload("res://Assets/Music/Electricity Short Circuit Sound Effect 1.mp3")
const _SFX_TRANSITION: AudioStream = preload("res://Assets/Music/Transition - Sound Effect HD.mp3")
const _SFX_BUILDING: AudioStream = preload("res://Assets/Music/Unique Cinematic Impact SFX.mp3")
const _SFX_LIGHTING: AudioStream = preload("res://Assets/Music/Big switch sound effect.mp3")

@export var _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant_v1.png")
@export var _SPEAKER: String = "Prompto"
@export var _INTRO_TEXT: String = "Ah thats a shame about the students....but your new hardware looks so good! Now we just need to power them up with electrcity. Where do you want to get electricity from?"

const _EXPANSION_TILE: String = "res://Assets/tiles/tiles_tree_grass_sheeps/tiles_grass_v6.png"
const _ELECTRIC_POLE_TILE: String = "res://Assets/tiles/tile_electric_pole_aiCenter.png"

const _FACTORY_VARIANTS: Array = [
	{
		"unlit": "res://Assets/tiles/tiles-aiCenter/tile-aiCenter-expansion-v6-lights-off.png",
		"lit": "res://Assets/tiles/tiles-aiCenter/tile-aiCenter-expansion-v6.png",
	},
	{
		"unlit": "res://Assets/tiles/tiles-aiCenter/tile-aiCenter-expansion-v8-lights-off.png",
		"lit": "res://Assets/tiles/tiles-aiCenter/tile-aiCenter-expansion-v8.png",
	},
]
const _LIT_MAX_DELAY: float = 1.5
const _POST_LIT_DELAY: float = 1.5

# Village prefixes that change variant when electricity is chosen
const _VILLAGE_LIGHTS: Dictionary = {
	"far": ["village-pontia-"],
	"close": ["village-petalia-", "village-fontania-"],
}
const _FACTORY_BUILD_MAX_DELAY: float = 1.5
const _POST_FACTORY_BUILD_DELAY: float = 1.0

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
		"label": "Further from village",
		"tint": Color(1.0, 0.0, 0.0, 0.706),
		"cells": [Vector2i(-5, 2)],
	},
	"close": {
		"label": "Close to village",
		"tint": Color(1.0, 0.0, 0.0, 0.706),
		"cells": [Vector2i(8, 0)],
	},
}

const _HOVER_FADE_DURATION: float = 0.08

var _clump_polygons: Dictionary = {}
var _ui_canvas: CanvasLayer
var _current_choice_index: int = 0
var _choose_btn: Button = null
var _ts_started: float = 0.0
var _cell_variants: Dictionary = {}

## Camera target used when the electricity choice buttons appear.
const _CHOICE_CAMERA_POS: Vector2 = Vector2(599.8859, 849.972)
const _CHOICE_CAMERA_ZOOM: Vector2 = Vector2(0.402628, 0.402628)
const _CAMERA_TRANSITION_DURATION: float = 1.0

func _stage_start() -> void:
	_ts_started = Time.get_unix_time_from_system()
	var chosen = _CHOICES[GameState.land_location]
	MusicManager.play_sfx(_SFX_BUILDING)
	# Animate the factory being built, picking a random variant per cell.
	_cell_variants.clear()
	for cell in chosen["cells"]:
		var variant_idx: int = randi() % _FACTORY_VARIANTS.size()
		_cell_variants[cell] = variant_idx
		var unlit_path: String = _FACTORY_VARIANTS[variant_idx]["unlit"]
		var delay: float = randf() * _FACTORY_BUILD_MAX_DELAY
		get_tree().create_timer(delay).timeout.connect(
			MapLayer.main.set_cell_by_texture.bind(cell, unlit_path), CONNECT_ONE_SHOT)

	await get_tree().create_timer(_FACTORY_BUILD_MAX_DELAY + _POST_FACTORY_BUILD_DELAY).timeout

	Newspaper.on_close.connect(_show_intro_dialogue, CONNECT_ONE_SHOT)
	Newspaper.show_article(Newspaper.Article.PRICES_LAPTOPS)


## Glides camera to show the electricity position choices
func _frame_electricity_view() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(camera, "position", _CHOICE_CAMERA_POS, _CAMERA_TRANSITION_DURATION)
	t.tween_property(camera, "zoom", _CHOICE_CAMERA_ZOOM, _CAMERA_TRANSITION_DURATION)


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

	_frame_electricity_view()

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
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	_ui_canvas.add_child(row)

	var prev_btn := Button.new()
	prev_btn.text = "<"
	prev_btn.custom_minimum_size = Vector2(80, 56)
	Stage.style_choice_button(prev_btn, Color(1, 1, 1, 0.25))
	row.add_child(prev_btn)
	prev_btn.pressed.connect(func(): _cycle_choice(-1))

	_choose_btn = Button.new()
	_choose_btn.custom_minimum_size = Vector2(280, 56)
	row.add_child(_choose_btn)
	_choose_btn.pressed.connect(func(): _on_choice(_ELECTRICITY_CHOICES.keys()[_current_choice_index]))

	var next_btn := Button.new()
	next_btn.text = ">"
	next_btn.custom_minimum_size = Vector2(80, 56)
	Stage.style_choice_button(next_btn, Color(1, 1, 1, 0.25))
	row.add_child(next_btn)
	next_btn.pressed.connect(func(): _cycle_choice(1))

	_current_choice_index = 0
	_show_only(_ELECTRICITY_CHOICES.keys()[_current_choice_index])
	Stage.fade_in_choice_buttons([prev_btn, _choose_btn, next_btn])
	Stage.pulse_choice_buttons([prev_btn, next_btn, _choose_btn])


func _cycle_choice(delta: int) -> void:
	var keys: Array = _ELECTRICITY_CHOICES.keys()
	_current_choice_index = (_current_choice_index + delta + keys.size()) % keys.size()
	_show_only(keys[_current_choice_index])
	MusicManager.play_sfx(_SFX_CYCLE)

func _show_only(active_key) -> void:
	for key in _clump_polygons:
		var alpha: float = 1.0 if key == active_key else 0.0
		_fade_clump(_clump_polygons[key], alpha)
	var tint: Color = _ELECTRICITY_CHOICES[active_key]["tint"]
	var accent := Color(tint.r, tint.g, tint.b, 1.0)
	_choose_btn.text = "Choose %s" % _ELECTRICITY_CHOICES[active_key]["label"]
	Stage.style_choice_button(_choose_btn, accent)

func _on_choice(key: String) -> void:
	GameState.electricity_choice = key
	var ts_chosen: float = Time.get_unix_time_from_system()
	var entry := Metrics.ChoiceEntry.new()
	entry.value = key
	entry.ts_started = _ts_started
	entry.ts_chosen = ts_chosen
	entry.ts_duration = ts_chosen - _ts_started
	GameState.metrics.electricity_choice = entry
	Dialogue.dismiss()
	if _ui_canvas:
		_ui_canvas.queue_free()
		_ui_canvas = null
	_clear_clumps()

	MusicManager.play_sfx(_SFX_ELECTRIC)
	for cell in _ELECTRICITY_CHOICES[key]["cells"]:
		MapLayer.main.set_cell_by_texture(cell, _ELECTRIC_POLE_TILE)

	await get_tree().create_timer(1.0).timeout

	var chosen = _CHOICES[GameState.land_location]
	for cell in chosen["cells"]:
		# Light up the same variant that was placed during construction.
		var variant_idx: int = _cell_variants.get(cell, 0)
		var lit_path: String = _FACTORY_VARIANTS[variant_idx]["lit"]
		var delay: float = randf() * _LIT_MAX_DELAY
		get_tree().create_timer(delay).timeout.connect(
			MapLayer.main.set_cell_by_texture.bind(cell, lit_path), CONNECT_ONE_SHOT)

	# Swap village lights based on electricity choice
	_swap_village_lights(key)

	await get_tree().create_timer(_LIT_MAX_DELAY + _POST_LIT_DELAY).timeout

	var article: int = Newspaper.Article.FARMLAND
	match key:
		"far":
			article = Newspaper.Article.SCIENTIST
		"close":
			article = Newspaper.Article.WINTER

	Newspaper.on_close.connect(func():
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
		opts,
		null
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
		MusicManager.play_sfx(_SFX_TRANSITION)
		Dialogue.dismiss()
		if _ui_canvas:
			_ui_canvas.queue_free()
			_ui_canvas = null
		finished.emit()
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

func _swap_village_lights(key: String) -> void:
	var prefixes: Array = _VILLAGE_LIGHTS.get(key, [])
	if prefixes.is_empty():
		return
	var tilemap := MapLayer.main
	if tilemap == null:
		return
	for cell in tilemap.get_used_cells():
		var src_id := tilemap.get_cell_source_id(cell)
		if src_id == -1:
			continue
		var atlas := tilemap.tile_set.get_source(src_id) as TileSetAtlasSource
		if atlas == null or atlas.texture == null:
			continue
		var file_name: String = atlas.texture.resource_path.get_file()
		if file_name.find("bridge") != -1:
			continue
		for prefix in prefixes:
			if file_name.begins_with(prefix):
				# Swap variant 0 -> 1: e.g. village-petalia-house-2-0- -> village-petalia-house-2-1-
				var new_name: String = file_name.replace("-0-400x484", "-1-400x484")
				if new_name != file_name:
					var new_path: String = atlas.texture.resource_path.get_base_dir() + "/" + new_name
					var delay: float = randf() * _LIT_MAX_DELAY
					get_tree().create_timer(delay).timeout.connect(
						tilemap.set_cell_by_texture.bind(cell, new_path), CONNECT_ONE_SHOT)
				break

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
