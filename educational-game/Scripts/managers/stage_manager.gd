extends Node

# The stage manager is responsible for going through the stages in order.

## Emitted when the stage changes.
signal stage_changed(index: int, stage: Stage)
## Emitted when there are no more stages to advance to.
signal no_more_stages

@export var stages: Array[PackedScene] = []

var _current: Stage
var _index: int = -1

var _debug_label_current: Label
var _debug_label_next: Label

func _ready() -> void:
	var section : VBoxContainer = Debug.add_section("Stage Manager")
	_debug_label_current = Debug.add_label("", section)
	_debug_label_next = Debug.add_label("", section)
	_advance()

## Move to the next stage
func _advance() -> void:
	# If we are in a stage, we end it.
	if _current:
		EventLogger.record("stage_end", {"index": _index, "name": _stage_label(_index)})
		_current._stage_end()
		_current.queue_free()
		_current = null
	_index += 1
	GameState.current_stage_index = _index
	if _index >= stages.size():
		_update_debug_labels()
		EventLogger.record("no_more_stages")
		no_more_stages.emit()
		return
	_current = stages[_index].instantiate()
	add_child(_current)

	# When the stage emits "finished", we call _advance again.
	_current.finished.connect(_advance, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
	_current._stage_start()
	_update_debug_labels()
	EventLogger.record("stage_start", {"index": _index, "name": _stage_label(_index)})
	stage_changed.emit(_index, _current)

func _update_debug_labels() -> void:
	_debug_label_current.text = "Current: %s" % _stage_label(_index)
	_debug_label_next.text = "Next:    %s" % _stage_label(_index + 1)

func _stage_label(i: int) -> String:
	if i < 0 or i >= stages.size():
		return "(none)"
	return "%d %s" % [i, stages[i].resource_path.get_file().get_basename()]
