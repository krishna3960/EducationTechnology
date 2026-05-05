extends Node

@export var speed: float = 0.05
var full_text_1: String = "Welcome to Mrs. Susan's lecture on using AI sustainably!\n\nAre you excited?"
var full_text_2: String = "Larger, more complex prompts use lot of resources.\n\nSo please be mindful of what you ask.\n\nLet's work through some examples together!"
var full_text_3: String = "You need to summarize a 3-page document. What's the most energy-conscious way to use AI for this?"
var full_text_4: String = "You want AI to help write a work email. Which prompt approach saves the most energy?"
var full_text_5: String = "You need to brainstorm ideas for a project. How do you prompt AI most sustainably?"

var label: Label
var timer: Timer
var glow_timer: float = 0.0
var current_quiz_scene: String = ""
var current_quiz_text: String = ""

var quiz_scenes = [
	["Sub-scene3", full_text_3],
	["Sub-scene4", full_text_4],
	["Sub-scene5", full_text_5],
]

func _ready():
	label = get_node("Sub-scene1/Label")
	label.text = ""
	
	get_node("Sub-scene1/Button").visible = false
	get_node("Sub-scene1/Speechbubble").visible = false
	
	get_node("Sub-scene2/Label").visible = false
	get_node("Sub-scene2/Button").visible = false
	get_node("Sub-scene2/Speechbubble").visible = false
	
	for q in quiz_scenes:
		hide_quiz_scene(q[0])
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = speed
	timer.timeout.connect(_show_next_char)
	
	await get_tree().create_timer(1.5).timeout
	timer.start()

func hide_quiz_scene(scene: String):
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

func start_quiz_scene(scene: String, full_text: String):
	get_node(scene + "/Label").visible = true
	label = get_node(scene + "/Label")
	label.text = ""
	current_quiz_scene = scene
	current_quiz_text = full_text
	if timer.timeout.is_connected(_show_quiz_char):
		timer.timeout.disconnect(_show_quiz_char)
	timer.timeout.connect(_show_quiz_char)
	timer.start()

func _show_quiz_char():
	if label.text.length() < current_quiz_text.length():
		label.text = current_quiz_text.left(label.text.length() + 1)
	else:
		timer.stop()
		get_node(current_quiz_scene + "/Button").visible = true
		get_node(current_quiz_scene + "/Button2").visible = true
		get_node(current_quiz_scene + "/Speechbubble").visible = true
		get_node(current_quiz_scene + "/Speechbubble2").visible = true

func on_quiz_wrong_pressed(scene: String):
	get_node(scene + "/Label").visible = false
	get_node(scene + "/Button").visible = false
	get_node(scene + "/Button2").visible = false
	get_node(scene + "/Speechbubble").visible = false
	get_node(scene + "/Speechbubble2").visible = false
	get_node(scene + "/Wrong").visible = true
	get_node(scene + "/Lesson").visible = true
	get_node(scene + "/Speechbubble3").visible = true
	get_node(scene + "/Button3").visible = true

func on_quiz_correct_pressed(scene: String):
	get_node(scene + "/Label").visible = false
	get_node(scene + "/Button").visible = false
	get_node(scene + "/Button2").visible = false
	get_node(scene + "/Speechbubble").visible = false
	get_node(scene + "/Speechbubble2").visible = false
	get_node(scene + "/Correct").visible = true
	get_node(scene + "/Lesson").visible = true
	get_node(scene + "/Speechbubble3").visible = true
	get_node(scene + "/Button3").visible = true

func clear_quiz_result(scene: String):
	get_node(scene + "/Wrong").visible = false
	get_node(scene + "/Correct").visible = false
	get_node(scene + "/Lesson").visible = false
	get_node(scene + "/Speechbubble3").visible = false
	get_node(scene + "/Button3").visible = false

func _show_next_char():
	if label.text.length() < full_text_1.length():
		label.text = full_text_1.left(label.text.length() + 1)
	else:
		timer.stop()
		get_node("Sub-scene1/Button").visible = true
		get_node("Sub-scene1/Speechbubble").visible = true

func on_scene1_button_pressed():
	get_node("Sub-scene1/Label").visible = false
	get_node("Sub-scene1/Button").visible = false
	get_node("Sub-scene1/Speechbubble").visible = false
	get_node("Sub-scene2/Label").visible = true
	label = get_node("Sub-scene2/Label")
	label.text = ""
	timer.timeout.disconnect(_show_next_char)
	timer.timeout.connect(_show_next_char_2)
	timer.start()

func _show_next_char_2():
	if label.text.length() < full_text_2.length():
		label.text = full_text_2.left(label.text.length() + 1)
	else:
		timer.stop()
		get_node("Sub-scene2/Button").visible = true
		get_node("Sub-scene2/Speechbubble").visible = true

func on_scene2_button_pressed():
	get_node("Sub-scene2/Label").visible = false
	get_node("Sub-scene2/Button").visible = false
	get_node("Sub-scene2/Speechbubble").visible = false
	timer.timeout.disconnect(_show_next_char_2)
	start_quiz_scene("Sub-scene3", full_text_3)

func on_scene3_button_pressed():
	on_quiz_wrong_pressed("Sub-scene3")

func on_scene3_button2_pressed():
	on_quiz_correct_pressed("Sub-scene3")

func on_scene3_button3_pressed():
	clear_quiz_result("Sub-scene3")
	start_quiz_scene("Sub-scene4", full_text_4)

func on_scene4_button_pressed():
	on_quiz_wrong_pressed("Sub-scene4")

func on_scene4_button2_pressed():
	on_quiz_correct_pressed("Sub-scene4")

func on_scene4_button3_pressed():
	clear_quiz_result("Sub-scene4")
	start_quiz_scene("Sub-scene5", full_text_5)

func on_scene5_button_pressed():
	on_quiz_wrong_pressed("Sub-scene5")

func on_scene5_button2_pressed():
	on_quiz_correct_pressed("Sub-scene5")

func on_scene5_button3_pressed():
	clear_quiz_result("Sub-scene5")
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _process(delta):
	var button1 = get_node("Sub-scene1/Button")
	var button2 = get_node("Sub-scene2/Button")
	if button1.visible:
		glow_timer += delta
		var glow = (sin(glow_timer * 3.0) + 1.0) / 2.0
		button1.add_theme_color_override("font_color", Color(glow, glow, glow, 1))
	if button2.visible:
		glow_timer += delta
		var glow = (sin(glow_timer * 3.0) + 1.0) / 2.0
		button2.add_theme_color_override("font_color", Color(glow, glow, glow, 1))
