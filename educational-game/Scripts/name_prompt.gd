extends Control

## Emitted once the player has entered a non-empty name.
signal submitted(player_name: String)

const MAX_NAME_LEN: int = 32
const FADE_DURATION: float = 0.5

@onready var _dim: ColorRect = $DimLayer/DimRect
@onready var _ui: CanvasLayer = $UILayer
@onready var _panel: Control = $UILayer/Panel
@onready var _edit: LineEdit = $UILayer/Panel/Margin/VBox/NameEdit
@onready var _btn: Button = $UILayer/Panel/Margin/VBox/ConfirmButton


func _ready() -> void:
	_edit.max_length = MAX_NAME_LEN
	_btn.pressed.connect(_try_submit)
	_edit.text_submitted.connect(func(_t: String): _try_submit())
	# Start invisible and fade in.
	_dim.modulate.a = 0.0
	_panel.modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.tween_property(_dim, "modulate:a", 1.0, FADE_DURATION)
	t.tween_property(_panel, "modulate:a", 1.0, FADE_DURATION)
	await t.finished
	_edit.grab_focus()


## Fades the prompt out.
func fade_out() -> void:
	var t := create_tween().set_parallel(true)
	t.tween_property(_dim, "modulate:a", 0.0, FADE_DURATION)
	t.tween_property(_panel, "modulate:a", 0.0, FADE_DURATION)
	await t.finished


func _try_submit() -> void:
	var n: String = _edit.text.strip_edges()
	if n.is_empty():
		_edit.grab_focus()
		return
	submitted.emit(n)
