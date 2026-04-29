extends Stage

var _debug_section: VBoxContainer


func _stage_start() -> void:

	# Example: adding UI to the debug panel
	_debug_section = Debug.add_section("Example Stage")
	Debug.add_button("Finish now", func(): finished.emit(), _debug_section)
	Debug.add_label("Click the world to finish too.", _debug_section)


	# Just end the stage immediately
	# finished.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		finished.emit()



func _stage_end() -> void:
	# Since the debug UI nodes belong to the debug panel, we need to explicitly remove the nodes
	_debug_section.queue_free()
