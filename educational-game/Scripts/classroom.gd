extends Node

signal exit_requested

@export var speed: float = 0.05

var full_text_1: String = "Welcome to Mrs. Susan's lecture on using AI sustainably!\n\nAre you excited?"
var full_text_2: String = "Larger, more complex prompts use lot of resources.\n\nSo please be mindful of what you ask.\n\nLet's work through some examples together!"
var full_text_3: String = "You need to summarize a 3-page document. What's the most energy-conscious way to use AI for this?"
var full_text_4: String = "You want AI to help write a work email. Which prompt approach saves the most energy?"
var full_text_5: String = "You need to brainstorm ideas for a project. How do you prompt AI most sustainably?"

var glow_timer: float = 0.0

var quiz_scenes := [
	["Sub-scene3", full_text_3],
	["Sub-scene4", full_text_4],
	["Sub-scene5", full_text_5],
]

var _timer: Timer
var _typing: bool = false
var _active_label: Label = null
var _full_text: String = ""
var _on_typing_done: Callable = Callable()
var _ts_started: float = 0.0
var _ts_skipped: Variant = null
var _ts_ended: float = 0.0


func _ready() -> void:
	get_node("Sub-scene1/Label").text = ""
	get_node("Sub-scene1/Button").visible = false
	get_node("Sub-scene1/Speechbubble").visible = false

	get_node("Sub-scene2/Label").visible = false
	get_node("Sub-scene2/Button").visible = false
	get_node("Sub-scene2/Speechbubble").visible = false

	for q in quiz_scenes:
		hide_quiz_scene(q[0])

	_timer = Timer.new()
	add_child(_timer)
	_timer.wait_time = speed
	_timer.timeout.connect(_on_type_tick)

	await get_tree().create_timer(1.5).timeout
	_start_typing(
		get_node("Sub-scene1/Label"),
		full_text_1,
		func():
			get_node("Sub-scene1/Button").visible = true
			get_node("Sub-scene1/Speechbubble").visible = true
	)


func _start_typing(label: Label, full_text: String, on_done: Callable) -> void:
	_typing = true
	_active_label = label
	_full_text = full_text
	_on_typing_done = on_done
	_ts_started = Time.get_unix_time_from_system()
	_ts_skipped = null
	_ts_ended = 0.0
	label.visible = true
	label.text = ""
	_timer.start()


func _on_type_tick() -> void:
	if not _typing or _active_label == null:
		return
	var current: int = _active_label.text.length()
	if current >= _full_text.length():
		_finish_typing()
		return
	_active_label.text = _full_text.left(current + 1)


func _finish_typing() -> void:
	_timer.stop()
	_typing = false
	if _active_label:
		_active_label.text = _full_text
	_ts_ended = Time.get_unix_time_from_system()
	var cb: Callable = _on_typing_done
	_on_typing_done = Callable()
	if cb.is_valid():
		cb.call()


func _unhandled_input(event: InputEvent) -> void:
	if not _typing:
		return
	var advance: bool = (event is InputEventMouseButton and event.pressed) \
		or event.is_action_pressed("ui_accept")
	if advance:
		get_viewport().set_input_as_handled()
		_ts_skipped = Time.get_unix_time_from_system()
		_finish_typing()


func hide_quiz_scene(scene: String) -> void:
	get_node(scene + "/Label").visible = false
	get_node(scene + "/Button").visible = false
	get_node(scene + "/Button2").visible = false
	get_node(scene + "/Speechbubble").visible = false
	get_node(scene + "/Speechbubble2").visible = false
	get_node(scene + "/Wrong").visible = false
	get_node(scene + "/Correct").visible = false
	get_node(scene + "/Lesson").visible = false
	get_node(scene + "/Speechbubble3").visible = false
	get_node(scene + "/Button3").visible = false


func start_quiz_scene(scene: String, full_text: String) -> void:
	_start_typing(
		get_node(scene + "/Label"),
		full_text,
		func():
			get_node(scene + "/Button").visible = true
			get_node(scene + "/Button2").visible = true
			get_node(scene + "/Speechbubble").visible = true
			get_node(scene + "/Speechbubble2").visible = true
	)


func _record_quiz_choice(scene: String, correct: bool, button_path: String) -> void:
	var entry := Metrics.ClassroomQuizEntry.new()
	entry.scene = scene
	entry.question = _full_text
	var btn := get_node_or_null(button_path) as Button
	entry.answer_chosen = btn.text if btn else ""
	var ts_answerchosen: float = Time.get_unix_time_from_system()
	entry.ts_started = _ts_started
	entry.ts_skipped = _ts_skipped
	entry.ts_ended = _ts_ended
	entry.ts_answerchosen = ts_answerchosen
	entry.ts_duration = ts_answerchosen - _ts_ended
	entry.answer_correct = correct
	GameState.metrics.classroom_quizzes.append(entry)


func on_quiz_wrong_pressed(scene: String) -> void:
	_record_quiz_choice(scene, false, scene + "/Button")
	get_node(scene + "/Label").visible = false
	get_node(scene + "/Button").visible = false
	get_node(scene + "/Button2").visible = false
	get_node(scene + "/Speechbubble").visible = false
	get_node(scene + "/Speechbubble2").visible = false
	get_node(scene + "/Wrong").visible = true
	get_node(scene + "/Lesson").visible = true
	get_node(scene + "/Speechbubble3").visible = true
	get_node(scene + "/Button3").visible = true


func on_quiz_correct_pressed(scene: String) -> void:
	_record_quiz_choice(scene, true, scene + "/Button2")
	get_node(scene + "/Label").visible = false
	get_node(scene + "/Button").visible = false
	get_node(scene + "/Button2").visible = false
	get_node(scene + "/Speechbubble").visible = false
	get_node(scene + "/Speechbubble2").visible = false
	get_node(scene + "/Correct").visible = true
	get_node(scene + "/Lesson").visible = true
	get_node(scene + "/Speechbubble3").visible = true
	get_node(scene + "/Button3").visible = true


func clear_quiz_result(scene: String) -> void:
	get_node(scene + "/Wrong").visible = false
	get_node(scene + "/Correct").visible = false
	get_node(scene + "/Lesson").visible = false
	get_node(scene + "/Speechbubble3").visible = false
	get_node(scene + "/Button3").visible = false


func on_scene1_button_pressed() -> void:
	get_node("Sub-scene1/Label").visible = false
	get_node("Sub-scene1/Button").visible = false
	get_node("Sub-scene1/Speechbubble").visible = false
	_start_typing(
		get_node("Sub-scene2/Label"),
		full_text_2,
		func():
			get_node("Sub-scene2/Button").visible = true
			get_node("Sub-scene2/Speechbubble").visible = true
	)


func on_scene2_button_pressed() -> void:
	get_node("Sub-scene2/Label").visible = false
	get_node("Sub-scene2/Button").visible = false
	get_node("Sub-scene2/Speechbubble").visible = false
	start_quiz_scene("Sub-scene3", full_text_3)


func on_scene3_button_pressed() -> void:
	on_quiz_wrong_pressed("Sub-scene3")


func on_scene3_button2_pressed() -> void:
	on_quiz_correct_pressed("Sub-scene3")


func on_scene3_button3_pressed() -> void:
	clear_quiz_result("Sub-scene3")
	start_quiz_scene("Sub-scene4", full_text_4)


func on_scene4_button_pressed() -> void:
	on_quiz_wrong_pressed("Sub-scene4")


func on_scene4_button2_pressed() -> void:
	on_quiz_correct_pressed("Sub-scene4")


func on_scene4_button3_pressed() -> void:
	clear_quiz_result("Sub-scene4")
	start_quiz_scene("Sub-scene5", full_text_5)


func on_scene5_button_pressed() -> void:
	on_quiz_wrong_pressed("Sub-scene5")


func on_scene5_button2_pressed() -> void:
	on_quiz_correct_pressed("Sub-scene5")


func on_scene5_button3_pressed() -> void:
	clear_quiz_result("Sub-scene5")
	exit_requested.emit()


func _process(delta: float) -> void:
	glow_timer += delta
	var glow: float = (sin(glow_timer * 3.0) + 1.0) / 2.0
	var color := Color(glow, glow, glow, 1)
	for path in [
		"Sub-scene1/Button",
		"Sub-scene2/Button",
	]:
		var btn := get_node_or_null(path) as Button
		if btn and btn.visible:
			btn.add_theme_color_override("font_color", color)
