extends Stage

const _SFX_CYCLE: AudioStream = preload("res://Assets/Music/Just A 1 Second Woosh Sound.mp3")
@export var _PORTRAIT: Texture2D = preload("res://Assets/scene_png/techgirl.png")
@export var _SPEAKER: String = "Ally"
var _intro_dismissed: bool = false

@export_category("Global Dashboard Settings")
@export var background_color: Color = Color("bebce9ff")
@export var title_text: String = "Final Report"
@export var subtitle_text: String = "See how your choices, {name}, shaped the real-world impact of your datacenter."

@export_category("Panel 1: Land Usage")
@export var p1_title: String = "Land Usage"
@export var p1_description: String = "AI center campuses require a lot of land. While the main buildings range in size from [b]7-40 hectares[/b] (10-55 football fields), the entire campus can span between [b]30 and 350 hectares[/b] (30-500 football fields). They not only take up a lot of space, but also transform the land they occupy. Often, [b]peri-urban and agricultural landscapes[/b] are used for these specialised industrial zones, which can result in the [b]loss of productive farmland[/b]."
@export var p1_choice_text: String = "Choice text updates dynamically"

@export_category("Panel 2: Hardware")
@export var p2_title: String = "Hardware"
@export var p2_description: String = "Villagers noticed laptops and other electronics becoming [b]more expensive[/b]. The same advanced chips powering your AI systems were driving up [b]global demand[/b]. Producing these chips requires many [b]rare metals[/b] such as copper, silicon and cobalt, as well as [b]purified water[/b]. The smaller the chips, the more precise and pure the resources have to be. The chips used in AI centres are [b]much more costly to produce[/b] than those used in general data centres."
@export var p2_choice_text: String = "You bought multiple servers from Joe's shop during the game to expand your AI center."

@export_category("Panel 3: Users")
@export var p3_title: String = "Users"
@export var p3_description: String = " "
@export var p3_choice_text: String = "ChatGPT has approximately 800 million weekly users"

@export_category("Panel 4: Energy Usage")
@export var p4_title: String = "Energy Usage"
@export var p4_description: String = "As CEO, your expansion contributes to the rapidly growing global energy demand of AI infrastructure, which currently accounts for [b]15-20% of data center electricity consumption[/b] worldwide. Overall, AI systems consume enough energy each year to power approximately [b]two to three and a half times[/b] the number of Swiss family households."
@export var p4_choice_text: String = "By redirecting energy towards the AI data center near Petalia, you have significantly reduced the amount of electricity available to local households."

@export_category("Panel 5: Water Usage")
@export var p5_title: String = "Water Usage"
@export var p5_description: String = "As a CEO, you are also responsible for the amount of water used by the AI center. Water is used not only to [b]cool down buildings and hardware[/b], but also during [b]chip manufacturing[/b] and by [b]power plant facilities[/b] that supply AI centers with power. The daily water footprint of AI systems is between [b]850 million and 2 billion litres[/b] every day — equivalent to the daily consumption of [b]5 to 13 million people[/b]."
@export var p5_choice_text: String = "Choice text updates dynamically"

@export_category("Panel 6: Carbon and Air Pollution")
@export var p6_title: String = "Carbon and Air Pollution"
@export var p6_description: String = "AI systems can have a carbon footprint between [b]32 and 80 million tons of CO₂[/b] — equivalent to the carbon footprint of [b]New York City[/b], or the emissions of [b]30-70 million economy class flights[/b] from Zurich to New York. Some AI centers use [b]gas power daily[/b], increasing air pollution and greenhouse gas emissions. Backup [b]diesel generators[/b] release harmful substances such as [b]fine particulate matter[/b] and [b]nitrogen oxides[/b], which can lead to respiratory or heart disease."
@export var p6_choice_text: String = ""

@export_category("Panel 7: Noise Pollution")
@export var p7_title: String = "Noise Pollution"
@export var p7_description: String = "Building an AI centre close to residential areas can cause [b]stress and sleep deprivation[/b]. Potential noise sources include [b]cooling systems[/b], [b]diesel generators[/b] and [b]whirring fans[/b], reaching up to [b]105 decibels[/b] — as loud as a jet flying overhead.\n\nFor reference: [b]Vacuum cleaner[/b] 60-85 dBA · [b]Blender[/b] 80-90 dBA · [b]Snow blower[/b] 105 dBA · [b]Baby crying[/b] 110 dBA · [b]Car horn[/b] 110 dBA."
@export var p7_choice_text: String = ""

@export_category("Cover Images")
@export var p1_cover: Texture2D
@export var p2_cover: Texture2D
@export var p3_cover: Texture2D
@export var p4_cover: Texture2D
@export var p5_cover: Texture2D
@export var p6_cover: Texture2D
@export var p7_cover: Texture2D

@onready var title_label: Label = $CanvasLayer/MarginContainer/MainLayout/HeaderContainer/Title
@onready var subtitle_label: Label = $CanvasLayer/MarginContainer/MainLayout/HeaderContainer/Subtitle
@onready var background: ColorRect = $CanvasLayer/Background

const _FLIP_DURATION: float = 0.15
	
func _ready() -> void:
	_apply_theme()
	_setup_flip_panels()
	_show_intro_dialogue()

func _show_intro_dialogue() -> void:
	var opts := DialogueOptions.new()
	opts.dim = false
	opts.auto_close = false
	Dialogue.on_typewriter_done.connect(_mount_ok_button, CONNECT_ONE_SHOT)
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, "This is the final report compiled by my team. Please read it carefully as it is very serious. Click any card to reveal its details, click again to hide them.", opts, null)

func _mount_ok_button() -> void:
	var btn := Button.new()
	btn.text = "Understood"
	btn.custom_minimum_size = Vector2(360, 80)
	Stage.style_choice_button(btn, Color(0.0, 0.8, 0.4, 1.0))
	btn.pressed.connect(func():
		MusicManager.play_sfx(_SFX_CYCLE)
		Dialogue.clear_choices()
		Dialogue.dismiss()
		_intro_dismissed = true
	)
	Dialogue.mount_choices([btn], "")
	Stage.fade_in_choice_buttons([btn])
	Stage.pulse_choice_buttons([btn])

func _apply_theme() -> void:
	if background:
		background.color = background_color
	if title_label:
		title_label.text = title_text.replace("{name}", GameState.player_name)
	if subtitle_label:
		subtitle_label.text = subtitle_text.replace("{name}", GameState.player_name)

	# LAND CHOICE
	match GameState.land_location:
		GameState.LandLocation.FIRST:
			p1_choice_text = "You built your AI centre on land that includes farmland."
		GameState.LandLocation.SECOND:
			p1_choice_text = "You built your AI center close to Petalia."
		GameState.LandLocation.THIRD:
			p1_choice_text = "You built your AI centre on land that used to be a forest."
		GameState.LandLocation.FOURTH:
			p1_choice_text = "You built your AI center on land that includes farmland."
		_:
			p1_choice_text = "You built your AI center on land that includes farmland."

	# ENERGY CHOICE
	if GameState.electricity_choice == "far":
		p4_choice_text = "By redirecting energy towards the AI data center, you have slightly reduced the amount of electricity available to Pontia."
	elif GameState.electricity_choice == "close":
		p4_choice_text = "By redirecting energy towards the AI data center near Petalia and Fontania, you have significantly reduced the amount of electricity available to local households."

	# WATER CHOICE
	if GameState.metrics.water_choices.size() >= 2:
		var choice1 = GameState.metrics.water_choices[0].value
		var choice2 = GameState.metrics.water_choices[1].value

		if choice1 == "north" and choice2 == "north":
			p5_choice_text = "By installing two water pumps on the North river, you have left Pontia with almost no water resources."
		elif choice1 == "west" and choice2 == "west":
			p5_choice_text = "Although installing two water pumps on the West River did not remove water resources from the villages, the nearby forest will be affected."
		elif choice1 == "east" and choice2 == "east":
			p5_choice_text = "By installing two water pumps on the East river, you have left Fontania with almost no water resources."
		elif (choice1 == "north" and choice2 == "west") or (choice1 == "west" and choice2 == "north"):
			p5_choice_text = "By installing a water pump near Pontia, you reduced their water resources to a level that they will notice, but which they can still live with. The forest next to the west river will also be affected."
		elif (choice1 == "north" and choice2 == "east") or (choice1 == "east" and choice2 == "north"):
			p5_choice_text = "By installing a water pump near Pontia and Fontania, you reduced their water resources to a level that they will notice, but which they can still live with."
		elif (choice1 == "west" and choice2 == "east") or (choice1 == "east" and choice2 == "west"):
			p5_choice_text = "By installing a water pump near Fontania, you reduced their water resources to a level that they will notice, but which they can still live with. The forest next to the west river will also be affected."
	else:
		p5_choice_text = "By installing two water pumps on the East river, you have left Fontania with almost no water resources."

	var top  = $CanvasLayer/MarginContainer/MainLayout/TopRow
	var mid  = $CanvasLayer/MarginContainer/MainLayout/MiddleRow
	var main = $CanvasLayer/MarginContainer/MainLayout

	# 1. Land Panel
	top.get_node("LandPanel/MarginContainer/PanelVBox/TopRow/Label").text = p1_title
	top.get_node("LandPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p1_description
	top.get_node("LandPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p1_choice_text
	# 2. Hardware Panel
	top.get_node("HWPanel/MarginContainer/PanelVBox/TopRow/Label").text = p2_title
	top.get_node("HWPanel/MarginContainer/PanelVBox/MiddleRow/VBoxContainer/RichTextLabel").text = p2_description
	top.get_node("HWPanel/MarginContainer/PanelVBox/MiddleRow/VBoxContainer/ChoiceBox/MarginContainer/Label").text = p2_choice_text
	# 3. Users Panel
	top.get_node("UsersPanel/MarginContainer/PanelVBox/TopRow/Label").text = p3_title
	top.get_node("UsersPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p3_choice_text
	# 4. Energy Panel
	mid.get_node("EnergyPanel/MarginContainer/PanelVBox/TopRow/Label").text = p4_title
	mid.get_node("EnergyPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p4_description
	mid.get_node("EnergyPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p4_choice_text
	# 5. Water Panel
	mid.get_node("WaterPanel/MarginContainer/PanelVBox/TopRow/Label").text = p5_title
	mid.get_node("WaterPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p5_description
	mid.get_node("WaterPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p5_choice_text
	# 6. Carbon and Air Pollution Panel
	main.get_node("AirPollutionPanel/MarginContainer/PanelVBox/TopRow/Label").text = p6_title
	main.get_node("AirPollutionPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p6_description
	# 7. Noise Pollution Panel
	mid.get_node("NoisePollutionPanel/MarginContainer/PanelVBox/TopRow/Label").text = p7_title
	mid.get_node("NoisePollutionPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p7_description


# ─── Flip mechanism ───────────────────────────────────────────────────────────

func _get_all_panels() -> Array:
	var top  = $CanvasLayer/MarginContainer/MainLayout/TopRow
	var mid  = $CanvasLayer/MarginContainer/MainLayout/MiddleRow
	var main = $CanvasLayer/MarginContainer/MainLayout
	return [
		top.get_node("LandPanel"),
		top.get_node("HWPanel"),
		top.get_node("UsersPanel"),
		mid.get_node("EnergyPanel"),
		mid.get_node("WaterPanel"),
		mid.get_node("NoisePollutionPanel"),
		main.get_node("AirPollutionPanel"),
	]

func _setup_flip_panels() -> void:
	var covers: Array[Texture2D] = [p1_cover, p2_cover, p3_cover, p4_cover, p5_cover, p6_cover, p7_cover]
	var panels := _get_all_panels()
	for i: int in panels.size():
		_init_flip(panels[i], covers[i])

func _set_mouse_filter_recursive(node: Control, filter: int) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = filter
			_set_mouse_filter_recursive(child, filter)

func _init_flip(panel_node: Control, cover_texture: Texture2D) -> void:
	var original_margin := panel_node.get_node("MarginContainer")
	var vbox := original_margin.get_node("PanelVBox")

	# Read title before we touch anything
	##var title_text_str: String = vbox.get_node("TopRow/Label").text

	# Enable scroll on RichTextLabels before reparenting
	for child in vbox.find_children("*", "RichTextLabel", true, false):
		var rtl := child as RichTextLabel
		rtl.scroll_active = true
		rtl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		rtl.bbcode_enabled = true

	# Hide original margin container — we replace it with our two faces
	original_margin.visible = false

	# --- Back face: wrap original_margin in a full-rect Control ---
	var back := original_margin.duplicate()
	back.name = "FlipBack"
	back.visible = false
	back.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Re-enable scroll on the duplicated RichTextLabels too
	for child in back.find_children("*", "RichTextLabel", true, false):
		var rtl := child as RichTextLabel
		rtl.scroll_active = true
		rtl.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# --- Front face ---
	var front := MarginContainer.new()
	front.name = "FlipFront"
	front.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	front.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	front.size_flags_vertical = Control.SIZE_EXPAND_FILL
	front.add_theme_constant_override("margin_left", 16)
	front.add_theme_constant_override("margin_right", 16)
	front.add_theme_constant_override("margin_top", 16)
	front.add_theme_constant_override("margin_bottom", 16)

	var front_vbox := VBoxContainer.new()
	front_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	front_vbox.add_theme_constant_override("separation", 12)
	front_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	front_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Duplicate the original TopRow so it looks identical to the flipped back
	var original_top_row := vbox.get_node("TopRow")
	var top_row_copy := original_top_row.duplicate()
	top_row_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	front_vbox.add_child(top_row_copy)
	# Cover image on the front face
	if cover_texture != null:
		var cover := TextureRect.new()
		cover.texture = cover_texture
		cover.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cover.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cover.size_flags_vertical = Control.SIZE_EXPAND_FILL
		front_vbox.add_child(cover)
	front.add_child(front_vbox)

	panel_node.add_child(front)
	panel_node.add_child(back)

	# Hover outline — sits above the faces, ignores mouse, fades in on hover.
	var outline := Panel.new()
	outline.name = "HoverOutline"
	outline.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outline.modulate.a = 0.0
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = Color(1.0, 0.85, 0.35, 1.0)
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(12)
	outline.add_theme_stylebox_override("panel", sb)
	panel_node.add_child(outline)
	panel_node.set_meta("_hover_outline", outline)

	panel_node.clip_contents = true
	panel_node.mouse_filter = Control.MOUSE_FILTER_STOP
	_set_mouse_filter_recursive(panel_node, Control.MOUSE_FILTER_PASS)
	outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_node.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_flip_panel(panel_node)
	)
	panel_node.mouse_entered.connect(func(): _set_hover(panel_node, true))
	panel_node.mouse_exited.connect(func(): _set_hover(panel_node, false))
	panel_node.set_meta("_flipped", false)


func _set_hover(panel_node: Control, on: bool) -> void:
	if not _intro_dismissed:
		return
	var outline: Panel = panel_node.get_meta("_hover_outline", null) as Panel
	if outline == null:
		return
	var prev: Tween = panel_node.get_meta("_hover_tween", null) as Tween
	if prev and prev.is_valid():
		prev.kill()
	var t := create_tween()
	t.tween_property(outline, "modulate:a", 1.0 if on else 0.0, 0.12)
	panel_node.set_meta("_hover_tween", t)

func _flip_panel(panel_node: Control) -> void:
	if not _intro_dismissed:
		return
	if panel_node.get_meta("_flipping", false):
		return
	panel_node.set_meta("_flipping", true)

	var flipped: bool = panel_node.get_meta("_flipped", false)
	var front := panel_node.get_node("FlipFront")
	var back  := panel_node.get_node("FlipBack")
	var show_node := back  if not flipped else front
	var hide_node := front if not flipped else back

	# First half: squish to zero
	var t1 := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t1.tween_property(panel_node, "scale:x", 0.0, _FLIP_DURATION)
	await t1.finished

	hide_node.visible = false
	show_node.visible = true

	# Second half: expand back to full
	var t2 := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t2.tween_property(panel_node, "scale:x", 1.0, _FLIP_DURATION)
	await t2.finished

	panel_node.set_meta("_flipped", not flipped)
	panel_node.set_meta("_flipping", false)


# ─── Stage lifecycle ──────────────────────────────────────────────────────────

func _stage_start() -> void:
	self.visible = true

func _stage_end() -> void:
	self.visible = false
