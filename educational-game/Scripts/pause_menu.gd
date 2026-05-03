extends CanvasLayer


func _ready() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	visible = paused


func _on_resume_pressed() -> void:
	_set_paused(false)


func _on_settings_pressed() -> void:
	# TODO: open settings
	print("Settings pressed")


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
