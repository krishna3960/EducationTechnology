extends Stage

const _PORTRAIT: Texture2D = preload("res://Assets/scene_png/assistant.png")
const _INTRO_TEXT: String = "We need to start by buying some land for the datacenter. Where should we build it?"

const _CHOICES: Array = [
	{ "label": "Near Farmland", "value": GameState.LandLocation.FARMLAND },
	{ "label": "Near Village", "value": GameState.LandLocation.VILLAGE },
	{ "label": "Near Forest", "value": GameState.LandLocation.FOREST },
]

var _ui: CanvasLayer


func _stage_start() -> void:
	Dialogue.on_typewriter_done.connect(_show_choices, CONNECT_ONE_SHOT)
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = false
	Dialogue.show_dialogue(_PORTRAIT, _INTRO_TEXT, opts)


func _show_choices() -> void:
	_ui = CanvasLayer.new()
	_ui.layer = 30
	add_child(_ui)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui.add_child(center)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	center.add_child(hbox)
	for choice in _CHOICES:
		var btn := Button.new()
		btn.text = choice["label"]
		btn.custom_minimum_size = Vector2(220, 80)
		btn.pressed.connect(func(): _on_choice(choice["value"]))
		hbox.add_child(btn)


func _on_choice(value: GameState.LandLocation) -> void:
	GameState.land_location = value
	Dialogue.dismiss()
	finished.emit()


func _stage_end() -> void:
	if _ui:
		_ui.queue_free()
		_ui = null
	if Dialogue.on_typewriter_done.is_connected(_show_choices):
		Dialogue.on_typewriter_done.disconnect(_show_choices)
	Dialogue.dismiss()
