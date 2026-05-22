extends Node
# The stage manager is responsible for going through the stages in order.
## Emitted when the stage changes.
signal stage_changed(index: int, stage: Stage)
## Emitted when there are no more stages to advance to.
signal no_more_stages
@export var stages: Array[PackedScene] = []
@export var stage_music: Array[AudioStream] = []

var _current: Stage
var _index: int = -1
var _ts_started: float = 0.0
var _debug_label_current: Label
var _debug_label_next: Label

var _skip_canvas: CanvasLayer
var _skip_btn: Button
const _SKIP_TARGETS: Array = [
	{"label": "Skip Intro", "stage_name": "1_land_choice_stage"},
	{"label": "Skip to Classroom", "stage_name": "04_classroom_tscn"},
]
var _skip_index: int = 0

func _ready() -> void:
	var section : VBoxContainer = Debug.add_section("Stage Manager")
	_debug_label_current = Debug.add_label("", section)
	_debug_label_next = Debug.add_label("", section)
	if GameState.skip_scenes_enabled:
		_create_skip_button()
	_advance()

func _create_skip_button() -> void:
	_skip_canvas = CanvasLayer.new()
	_skip_canvas.layer = 100
	add_child(_skip_canvas)
	_skip_btn = Button.new()
	_skip_btn.text = _SKIP_TARGETS[0]["label"]
	_skip_btn.modulate = Color(1, 1, 0.4, 1)
	_skip_btn.z_index = 200
	_skip_btn.offset_left = 24.0
	_skip_btn.offset_top = 24.0
	_skip_btn.offset_right = 244.0
	_skip_btn.offset_bottom = 72.0
	_skip_btn.add_theme_font_size_override("font_size", 22)
	_skip_btn.disabled = not GameState.user_consented
	_skip_canvas.add_child(_skip_btn)
	_skip_btn.pressed.connect(_on_skip_pressed)

func _process(_delta: float) -> void:
	if _skip_btn != null and _skip_btn.disabled and GameState.user_consented:
		_skip_btn.disabled = false

func _on_skip_pressed() -> void:
	if _skip_index >= _SKIP_TARGETS.size():
		return
	var target_name: String = _SKIP_TARGETS[_skip_index]["stage_name"]
	var target_idx: int = -1
	for i in stages.size():
		if stages[i].resource_path.get_file().get_basename() == target_name:
			target_idx = i
			break
	if target_idx == -1 or target_idx <= _index:
		return
	_skip_to(target_idx)
	_skip_index += 1
	if _skip_index < _SKIP_TARGETS.size():
		_skip_btn.text = _SKIP_TARGETS[_skip_index]["label"]
	else:
		_skip_btn.hide()

func _skip_to(target_idx: int) -> void:
	if _current:
		if _current.finished.is_connected(_advance):
			_current.finished.disconnect(_advance)
		_current._stage_end()
		_current.queue_free()
		_current = null
	_index = target_idx - 1
	_advance()
## Move to the next stage
func _advance() -> void:
	# If we are in a stage, we end it.
	if _current:
		var ts_ended: float = Time.get_unix_time_from_system()
		var entry := Metrics.StageEntry.new()
		entry.index = _index
		entry.name = _stage_label(_index)
		entry.ts_started = _ts_started
		entry.ts_ended = ts_ended
		entry.ts_duration = ts_ended - _ts_started
		GameState.metrics.stages.append(entry)
		_current._stage_end()
		_current.queue_free()
		_current = null
	_index += 1
	GameState.current_stage_index = _index
	if _index >= stages.size():
		_update_debug_labels()
		no_more_stages.emit()
		return
	_current = stages[_index].instantiate()
	add_child(_current)
	# When the stage emits "finished", we call _advance again.
	_current.finished.connect(_advance, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
	_current._stage_start()
	_update_debug_labels()
	_ts_started = Time.get_unix_time_from_system()
	stage_changed.emit(_index, _current)
	if stage_music.size() > _index and stage_music[_index] != null:
		MusicManager.play(stage_music[_index])
func _update_debug_labels() -> void:
	_debug_label_current.text = "Current: %s" % _stage_label(_index)
	_debug_label_next.text = "Next:    %s" % _stage_label(_index + 1)
func _stage_label(i: int) -> String:
	if i < 0 or i >= stages.size():
		return "(none)"
	return "%d %s" % [i, stages[i].resource_path.get_file().get_basename()]
