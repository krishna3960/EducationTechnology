extends Stage

const CLASSROOM_SCENE = preload("res://Scenes/Classroom.tscn")
var _classroom

func _stage_start() -> void:
	_classroom = CLASSROOM_SCENE.instantiate()
	add_child(_classroom)
	_classroom.exit_requested.connect(func(): finished.emit())

func _stage_end() -> void:
	if _classroom:
		_classroom.queue_free()
