extends Node

const _SFX_CORRECT: AudioStream = preload("res://Assets/Music/Kids Cheering - Sound Effect (HD).mp3")
const _SFX_WRONG: AudioStream = preload("res://Assets/Music/aww sound effect ( 4K ).mp3")

signal exit_requested

@export var speed: float = 0.025

var full_text_1: String = "Welcome to Mrs. Susan's lecture on using AI sustainably!\n\nAre you excited?"
var full_text_2: String = "Larger, more complex prompts use lot of resources.\n\nSo please be mindful of what you ask.\n\nLet's work through some examples together!"
var full_text_3: String = "You need to summarize a 3-page document. What's the most energy-conscious way to use AI for this?"
var full_text_4: String = "You want AI to help write a work email. Which prompt approach saves the most energy?"
var full_text_5: String = "You need to brainstorm ideas for a project. How do you prompt AI most sustainably?"

var glow_timer: float = 0.0

# same as dialogue
const _SQUEEZE_AMOUNT_RANGE := Vector2(0.02, 0.04)
const _SQUEEZE_DURATION_RANGE := Vector2(0.15, 0.29)
const _SQUEEZE_CHARS_RANGE := Vector2i(2, 4)
const _SILENT_CHARS: String = " \t\n.,!?;:-—\""

@onready var _teacher: Sprite2D = $Teacher
var _teacher_base_scale: Vector2 = Vector2.ONE
var _squeeze_tween: Tween
var _last_char_count: int = 0
var _chars_since_squeeze: int = 0
var _next_squeeze_at: int = 0

const _QUIZ_PATHS: Dictionary = {
	"Sub-scene3": {
		"root": "Sub-scene3/Node2D3",
		"wrong_bubble": "Sub-scene3/Node2D3/Node2D3/Speechbubble",
		"wrong_button": "Sub-scene3/Node2D3/Node2D3/Button2",
		"correct_bubble": "Sub-scene3/Node2D3/Node2D2/Speechbubble2",
		"correct_button": "Sub-scene3/Node2D3/Node2D2/Button",
		"continue_bubble": "Sub-scene3/Node2D3/Node2D/Speechbubble3",
		"continue_button": "Sub-scene3/Node2D3/Node2D/Button3",
	},
	"Sub-scene4": {
		"root": "Sub-scene4/Node2D3",
		"wrong_bubble": "Sub-scene4/Node2D3/Node2D3/Speechbubble",
		"wrong_button": "Sub-scene4/Node2D3/Node2D3/Button",
		"correct_bubble": "Sub-scene4/Node2D3/Node2D2/Speechbubble2",
		"correct_button": "Sub-scene4/Node2D3/Node2D2/Button2",
		"continue_bubble": "Sub-scene4/Node2D3/Node2D/Speechbubble3",
		"continue_button": "Sub-scene4/Node2D3/Node2D/Button3",
	},
	"Sub-scene5": {
		"root": "Sub-scene5/Node2D4",
		"wrong_bubble": "Sub-scene5/Node2D4/Node2D/Speechbubble",
		"wrong_button": "Sub-scene5/Node2D4/Node2D/Button",
		"correct_bubble": "Sub-scene5/Node2D4/Node2D3/Speechbubble2",
		"correct_button": "Sub-scene5/Node2D4/Node2D3/Button2",
		"continue_bubble": "Sub-scene5/Node2D4/Node2D2/Speechbubble3",
		"continue_button": "Sub-scene5/Node2D4/Node2D2/Button3",
	},
}

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
	if _teacher:
		_teacher_base_scale = _teacher.scale
	get_node("Sub-scene1/Node2D2/Label").text = ""
	get_node("Sub-scene1/Node2D2/Option/Button").visible = false
	get_node("Sub-scene1/Node2D2/Option/Speechbubble").visible = false

	get_node("Sub-scene2/Node2D/Bubble/Label").visible = false
	get_node("Sub-scene2/Node2D/Button").visible = false
	get_node("Sub-scene2/Node2D/Bubble/Speechbubble").visible = false

	for q in quiz_scenes:
		hide_quiz_scene(q[0])

	_timer = Timer.new()
	add_child(_timer)
	_timer.wait_time = speed
	_timer.timeout.connect(_on_type_tick)

	await get_tree().create_timer(1.5).timeout
	_start_typing(
		get_node("Sub-scene1/Node2D2/Label"),
		full_text_1,
		func():
			get_node("Sub-scene1/Node2D2/Option/Button").visible = true
			get_node("Sub-scene1/Node2D2/Option/Speechbubble").visible = true
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
	_last_char_count = 0
	_chars_since_squeeze = 0
	_next_squeeze_at = randi_range(_SQUEEZE_CHARS_RANGE.x, _SQUEEZE_CHARS_RANGE.y)
	_timer.start()


func _on_type_tick() -> void:
	if not _typing or _active_label == null:
		return
	var current: int = _active_label.text.length()
	if current >= _full_text.length():
		_finish_typing()
		return
	_active_label.text = _full_text.left(current + 1)
	# Squeeze the teacher every N non-silent characters, same as the dialogue.
	var ch: String = _full_text.substr(current, 1)
	_last_char_count = current + 1
	if not _SILENT_CHARS.contains(ch):
		_chars_since_squeeze += 1
		if _chars_since_squeeze >= _next_squeeze_at:
			_trigger_squeeze()
			_chars_since_squeeze = 0
			_next_squeeze_at = randi_range(_SQUEEZE_CHARS_RANGE.x, _SQUEEZE_CHARS_RANGE.y)


func _trigger_squeeze() -> void:
	if _teacher == null:
		return
	if _squeeze_tween and _squeeze_tween.is_valid():
		_squeeze_tween.kill()
	var amount: float = randf_range(_SQUEEZE_AMOUNT_RANGE.x, _SQUEEZE_AMOUNT_RANGE.y)
	var dur: float = randf_range(_SQUEEZE_DURATION_RANGE.x, _SQUEEZE_DURATION_RANGE.y)
	var squashed: float = _teacher_base_scale.y * (1.0 - amount)
	_squeeze_tween = create_tween()
	_squeeze_tween.tween_property(_teacher, "scale:y", squashed, dur * 0.4) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_squeeze_tween.tween_property(_teacher, "scale:y", _teacher_base_scale.y, dur * 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _stop_squeeze() -> void:
	if _squeeze_tween and _squeeze_tween.is_valid():
		_squeeze_tween.kill()
	if _teacher:
		_teacher.scale = _teacher_base_scale


func _finish_typing() -> void:
	_timer.stop()
	_typing = false
	if _active_label:
		_active_label.text = _full_text
	_stop_squeeze()
	_ts_ended = Time.get_unix_time_from_system()
	var cb: Callable = _on_typing_done
	_on_typing_done = Callable()
	if cb.is_valid():
		cb.call()


## Skip dialog on click
func _input(event: InputEvent) -> void:
	if not _typing:
		return
	var advance: bool = (event is InputEventMouseButton and event.pressed) \
		or event.is_action_pressed("ui_accept")
	if advance:
		get_viewport().set_input_as_handled()
		_ts_skipped = Time.get_unix_time_from_system()
		_finish_typing()


func hide_quiz_scene(scene: String) -> void:
	var p: Dictionary = _QUIZ_PATHS[scene]
	var root: String = p["root"]
	get_node(root + "/Label").visible = false
	get_node(root + "/Wrong").visible = false
	get_node(root + "/Correct").visible = false
	get_node(root + "/Lesson").visible = false
	get_node(p["wrong_bubble"]).visible = false
	get_node(p["wrong_button"]).visible = false
	get_node(p["correct_bubble"]).visible = false
	get_node(p["correct_button"]).visible = false
	get_node(p["continue_bubble"]).visible = false
	get_node(p["continue_button"]).visible = false


func start_quiz_scene(scene: String, full_text: String) -> void:
	var p: Dictionary = _QUIZ_PATHS[scene]
	var root: String = p["root"]
	_start_typing(
		get_node(root + "/Label"),
		full_text,
		func():
			get_node(p["wrong_bubble"]).visible = true
			get_node(p["wrong_button"]).visible = true
			get_node(p["correct_bubble"]).visible = true
			get_node(p["correct_button"]).visible = true
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
	MusicManager.play_sfx(_SFX_WRONG)
	var p: Dictionary = _QUIZ_PATHS[scene]
	var root: String = p["root"]
	_record_quiz_choice(scene, false, p["wrong_button"])
	get_node(root + "/Label").visible = false
	get_node(p["wrong_bubble"]).visible = false
	get_node(p["wrong_button"]).visible = false
	get_node(p["correct_bubble"]).visible = false
	get_node(p["correct_button"]).visible = false
	get_node(root + "/Wrong").visible = true
	get_node(root + "/Lesson").visible = true
	get_node(p["continue_bubble"]).visible = true
	get_node(p["continue_button"]).visible = true


func on_quiz_correct_pressed(scene: String) -> void:
	MusicManager.play_sfx(_SFX_CORRECT)
	var p: Dictionary = _QUIZ_PATHS[scene]
	var root: String = p["root"]
	_record_quiz_choice(scene, true, p["correct_button"])
	get_node(root + "/Label").visible = false
	get_node(p["wrong_bubble"]).visible = false
	get_node(p["wrong_button"]).visible = false
	get_node(p["correct_bubble"]).visible = false
	get_node(p["correct_button"]).visible = false
	get_node(root + "/Correct").visible = true
	get_node(root + "/Lesson").visible = true
	get_node(p["continue_bubble"]).visible = true
	get_node(p["continue_button"]).visible = true


func clear_quiz_result(scene: String) -> void:
	var p: Dictionary = _QUIZ_PATHS[scene]
	var root: String = p["root"]
	get_node(root + "/Wrong").visible = false
	get_node(root + "/Correct").visible = false
	get_node(root + "/Lesson").visible = false
	get_node(p["continue_bubble"]).visible = false
	get_node(p["continue_button"]).visible = false


func on_scene1_button_pressed() -> void:
	MusicManager.play_sfx(_SFX_CORRECT)
	get_node("Sub-scene1/Node2D2/Label").visible = false
	get_node("Sub-scene1/Node2D2/Option/Button").visible = false
	get_node("Sub-scene1/Node2D2/Option/Speechbubble").visible = false
	_start_typing(
		get_node("Sub-scene2/Node2D/Bubble/Label"),
		full_text_2,
		func():
			get_node("Sub-scene2/Node2D/Button").visible = true
			get_node("Sub-scene2/Node2D/Bubble/Speechbubble").visible = true
	)


func on_scene2_button_pressed() -> void:
	MusicManager.play_sfx(_SFX_CORRECT)
	get_node("Sub-scene2/Node2D/Bubble/Label").visible = false
	get_node("Sub-scene2/Node2D/Button").visible = false
	get_node("Sub-scene2/Node2D/Bubble/Speechbubble").visible = false
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
		"Sub-scene1/Node2D2/Option/Button",
		"Sub-scene2/Node2D/Button",
	]:
		var btn := get_node_or_null(path) as Button
		if btn and btn.visible:
			btn.add_theme_color_override("font_color", color)
