extends CanvasLayer

const _FADE_DURATION: float = 0.2

@onready var _background: ColorRect = $Background
var _tween: Tween


func _ready() -> void:
	layer = RenderLayers.PAUSE_MENU
	visible = false
	_background.modulate.a = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func _set_paused(paused: bool) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	if paused:
		get_tree().paused = true
		visible = true
		_tween = create_tween()
		_tween.tween_property(_background, "modulate:a", 1.0, _FADE_DURATION)
	else:
		_tween = create_tween()
		_tween.tween_property(_background, "modulate:a", 0.0, _FADE_DURATION)
		await _tween.finished
		visible = false
		get_tree().paused = false


func _on_resume_pressed() -> void:
	_set_paused(false)


func _on_quit_pressed() -> void:
	get_tree().paused = false
	EventLogger.submit_and_quit()
