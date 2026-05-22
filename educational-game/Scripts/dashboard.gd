# dashboard.gd
# Final summary dashboard. Extends CanvasLayer — same pattern as Shop.tscn / shop.gd.
# The ENTIRE UI is built in code inside _build_ui(). No nodes need to be added in the
# Godot IDE. The only manual step is attaching this script to the root CanvasLayer node
# in Dashboard.tscn (already done if you use the provided Dashboard.tscn).
extends CanvasLayer

signal exit_requested

# ─────────────────────────────────────────────────────────────────
#  COLOUR PALETTE  ← edit here to retheme everything
# ─────────────────────────────────────────────────────────────────
const COLOR_BG             := Color(0.10, 0.13, 0.20, 1.0)   # full-screen bg
const COLOR_CARD_BG        := Color(0.14, 0.18, 0.27, 1.0)   # card surface
const COLOR_HEADER_BG      := Color(0.08, 0.11, 0.18, 1.0)   # title + footer strip
const COLOR_TEXT_HEADING   := Color(0.96, 0.96, 0.96, 1.0)
const COLOR_TEXT_BODY      := Color(0.72, 0.78, 0.85, 1.0)
const COLOR_TEXT_SPECIAL   := Color(0.98, 0.80, 0.28, 1.0)   # ★ callout
const COLOR_TITLE_RULE     := Color(0.35, 0.75, 0.85, 1.0)   # top accent bar
const COLOR_CHART_BG       := Color(0.08, 0.10, 0.17, 1.0)

# Per-resource accent colours (stripe, stat number, icon bg tint)
const COLOR_WATER   := Color(0.22, 0.60, 0.87, 1.0)
const COLOR_ENERGY  := Color(0.95, 0.72, 0.15, 1.0)
const COLOR_CO2     := Color(0.20, 0.72, 0.52, 1.0)
const COLOR_COMPUTE := Color(0.62, 0.38, 0.88, 1.0)

# ─────────────────────────────────────────────────────────────────
#  FONT SIZES
# ─────────────────────────────────────────────────────────────────
const FS_TITLE    := 52
const FS_SUBTITLE := 22
const FS_HEADING  := 24
const FS_BODY     := 17
const FS_SPECIAL  := 15
const FS_STAT     := 34   # big number top-right of each card
const FS_STAT_SUB := 13
const FS_BUTTON   := 24

# ─────────────────────────────────────────────────────────────────
#  ANIMATION
# ─────────────────────────────────────────────────────────────────
const FADE_DURATION := 0.45
const CARD_STAGGER  := 0.10

# ─────────────────────────────────────────────────────────────────
#  CARD DATA  ← add / edit entries here to change content
#
#  Keys per card:
#    title        String          card heading
#    accent       Color           stripe + stat + icon tint
#    icon_char    String          single emoji for the icon box
#    body_lines   Array[String]   lines of body text
#    special_text String          ★ callout line (amber)
#    stat_value   String          large number shown top-right
#    stat_label   String          small label under that number
#    chart_type   String          "pie"  or  "bar"
#    chart_data   Array[Dict]     [{label, value, color}]
#    choice_key   String          "" | "land" | "electricity" | "water"
# ─────────────────────────────────────────────────────────────────
var card_data: Array[Dictionary] = [
	{
		"title":       "Water usage",
		"accent":      COLOR_WATER,
		"icon_char":   "💧",
		"body_lines": [
			"Training and running AI models requires",
			"significant water for server cooling.",
			"Data centres can use millions of litres",
			"of fresh water every single day.",
		],
		"special_text": "1 query ≈ 500 ml of fresh water",
		"stat_value":  "500 ml",
		"stat_label":  "per query",
		"chart_type":  "pie",
		"chart_data":  [
			{"label": "Cooling",  "value": 65.0, "color": Color(0.22, 0.60, 0.87, 1.0)},
			{"label": "Humidity", "value": 20.0, "color": Color(0.52, 0.76, 0.92, 1.0)},
			{"label": "Other",    "value": 15.0, "color": Color(0.30, 0.42, 0.58, 1.0)},
		],
		"choice_key": "water",
	},
	{
		"title":       "Energy",
		"accent":      COLOR_ENERGY,
		"icon_char":   "⚡",
		"body_lines": [
			"Electricity powers every computation.",
			"A single large prompt can power an LED",
			"bulb for over 2 minutes.",
			"Renewable energy reduces this impact.",
		],
		"special_text": "1 prompt ≈ 2 min of LED-bulb power",
		"stat_value":  "0.3 Wh",
		"stat_label":  "per query",
		"chart_type":  "bar",
		"chart_data":  [
			{"label": "Web search", "value": 10.0,  "color": Color(0.42, 0.68, 0.32, 1.0)},
			{"label": "Simple AI",  "value": 35.0,  "color": Color(0.95, 0.72, 0.15, 1.0)},
			{"label": "Complex AI", "value": 100.0, "color": Color(0.88, 0.32, 0.28, 1.0)},
		],
		"choice_key": "electricity",
	},
	{
		"title":       "CO₂ footprint",
		"accent":      COLOR_CO2,
		"icon_char":   "🌿",
		"body_lines": [
			"Every AI request produces CO₂ equivalent",
			"emissions via electricity use.",
			"Training large models can emit as much",
			"CO₂ as five transatlantic flights.",
		],
		"special_text": "1 query ≈ one human breath of CO₂",
		"stat_value":  "4 g",
		"stat_label":  "CO₂ per query",
		"chart_type":  "pie",
		"chart_data":  [
			{"label": "Inference", "value": 55.0, "color": Color(0.20, 0.72, 0.52, 1.0)},
			{"label": "Training",  "value": 30.0, "color": Color(0.38, 0.82, 0.62, 1.0)},
			{"label": "Hardware",  "value": 15.0, "color": Color(0.18, 0.42, 0.32, 1.0)},
		],
		"choice_key": "",
	},
	{
		"title":       "Compute & land",
		"accent":      COLOR_COMPUTE,
		"icon_char":   "🖥️",
		"body_lines": [
			"Server farms need vast physical space,",
			"specialist hardware & rare minerals.",
			"Hardware supply chains create significant",
			"environmental and social costs.",
		],
		"special_text": "Buying 5 racks raised all other prices!",
		"stat_value":  "5",
		"stat_label":  "server racks bought",
		"chart_type":  "bar",
		"chart_data":  [
			{"label": "Minerals",  "value": 40.0, "color": Color(0.62, 0.38, 0.88, 1.0)},
			{"label": "Assembly",  "value": 25.0, "color": Color(0.72, 0.52, 0.92, 1.0)},
			{"label": "Transport", "value": 20.0, "color": Color(0.82, 0.66, 0.96, 1.0)},
			{"label": "E-waste",   "value": 15.0, "color": Color(0.42, 0.24, 0.62, 1.0)},
		],
		"choice_key": "land",
	},
]

const DASHBOARD_TITLE    := "Your AI footprint"
const DASHBOARD_SUBTITLE := "See how the choices you made shaped the real-world impact of your datacenter."

# ─────────────────────────────────────────────────────────────────
#  INTERNAL STATE
# ─────────────────────────────────────────────────────────────────
var _card_nodes:  Array[Control] = []
var _chart_nodes: Array[Control] = []
var _tt_panel:    PanelContainer


# ═══════════════════════════════════════════════════════════════
#  ENTRY POINT
# ═══════════════════════════════════════════════════════════════

func _ready() -> void:
	layer = RenderLayers.NEWSPAPER_UI + 10
	_build_ui()
	_animate_in()


# ═══════════════════════════════════════════════════════════════
#  TOP-LEVEL UI CONSTRUCTION
#
#  Tree built here (everything via add_child — no IDE nodes needed):
#
#  CanvasLayer  (this script)
#  ├── ColorRect          full-screen background
#  ├── PanelContainer     floating tooltip (hidden until hover)
#  └── ScrollContainer    full-screen scroll
#      └── VBoxContainer  root column
#          └── MarginContainer  padding 60 px L/R
#              └── VBoxContainer  inner column
#                  ├── VBoxContainer  title block
#                  ├── GridContainer  2-column bento grid
#                  │   ├── PanelContainer  card 0
#                  │   ├── PanelContainer  card 1
#                  │   ├── PanelContainer  card 2
#                  │   └── PanelContainer  card 3
#                  └── HBoxContainer  footer (Return button)
# ═══════════════════════════════════════════════════════════════

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.color = COLOR_BG
	add_child(bg)

	_tt_panel = _make_tooltip_panel()
	add_child(_tt_panel)

	var scroll := ScrollContainer.new()
	scroll.anchors_preset = Control.PRESET_FULL_RECT
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var root_vbox := VBoxContainer.new()
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_theme_constant_override("separation", 0)
	scroll.add_child(root_vbox)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   60)
	margin.add_theme_constant_override("margin_right",  60)
	margin.add_theme_constant_override("margin_top",    44)
	margin.add_theme_constant_override("margin_bottom", 48)
	root_vbox.add_child(margin)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 28)
	margin.add_child(inner)

	_build_title_block(inner)
	_build_grid(inner)
	_build_footer(inner)


# ─────────────────────────────────────────────────────────────────
#  TOOLTIP PANEL  (floats at mouse position, shared by all charts)
# ─────────────────────────────────────────────────────────────────

func _make_tooltip_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.visible = false
	panel.z_index = 300
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sty := StyleBoxFlat.new()
	sty.bg_color = Color(0.04, 0.07, 0.13, 0.96)
	sty.set_corner_radius_all(6)
	sty.set_border_width_all(1)
	sty.border_color = Color(0.38, 0.78, 1.0, 0.55)
	sty.content_margin_left   = 10
	sty.content_margin_right  = 10
	sty.content_margin_top    = 5
	sty.content_margin_bottom = 5
	panel.add_theme_stylebox_override("panel", sty)

	var lbl := Label.new()
	lbl.name = "TipLabel"
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(lbl)
	return panel


# ─────────────────────────────────────────────────────────────────
#  TITLE BLOCK
#   VBoxContainer
#   ├── ColorRect        4 px accent rule
#   ├── Control          8 px spacer
#   ├── Label            title
#   └── Label            subtitle
# ─────────────────────────────────────────────────────────────────

func _build_title_block(parent: Control) -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	parent.add_child(vbox)

	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 4)
	rule.color = COLOR_TITLE_RULE
	vbox.add_child(rule)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	var title := Label.new()
	title.text = DASHBOARD_TITLE
	title.add_theme_font_size_override("font_size", FS_TITLE)
	title.add_theme_color_override("font_color", COLOR_TEXT_HEADING)
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = DASHBOARD_SUBTITLE
	sub.add_theme_font_size_override("font_size", FS_SUBTITLE)
	sub.add_theme_color_override("font_color", COLOR_TEXT_BODY)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(sub)


# ─────────────────────────────────────────────────────────────────
#  BENTO GRID  (2 columns × 2 rows)
# ─────────────────────────────────────────────────────────────────

func _build_grid(parent: Control) -> void:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	parent.add_child(grid)

	_card_nodes.clear()
	_chart_nodes.clear()

	for i: int in card_data.size():
		var card := _make_card(card_data[i])
		card.modulate.a = 0.0   # starts invisible; _animate_in fades it in
		grid.add_child(card)
		_card_nodes.append(card)


# ─────────────────────────────────────────────────────────────────
#  CARD  (Variant B layout: stat top-right, chart bottom-right)
#
#  PanelContainer  (card root)
#  └── VBoxContainer
#      ├── ColorRect              4 px accent stripe
#      └── MarginContainer        14 px padding
#          └── VBoxContainer      card content column
#              ├── HBoxContainer  header row
#              │   ├── HBoxContainer  icon + title (left)
#              │   └── VBoxContainer  stat number + label (right)
#              └── HBoxContainer  body row
#                  ├── VBoxContainer  text + callouts (left)
#                  └── VBoxContainer  chart + legend  (right)
# ─────────────────────────────────────────────────────────────────

func _make_card(data: Dictionary) -> Control:
	var accent: Color = data.get("accent", COLOR_WATER)

	# ── Root panel ──
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size   = Vector2(0, 300)
	var psty := StyleBoxFlat.new()
	psty.bg_color = COLOR_CARD_BG
	psty.set_corner_radius_all(14)
	psty.set_border_width_all(2)
	psty.border_color = Color(accent.r, accent.g, accent.b, 0.40)
	psty.content_margin_left   = 0
	psty.content_margin_right  = 0
	psty.content_margin_top    = 0
	psty.content_margin_bottom = 0
	panel.add_theme_stylebox_override("panel", psty)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	panel.add_child(col)

	# Accent stripe
	var stripe := ColorRect.new()
	stripe.custom_minimum_size = Vector2(0, 5)
	stripe.color = accent
	col.add_child(stripe)

	# Inner margin
	var mg := MarginContainer.new()
	mg.add_theme_constant_override("margin_left",   16)
	mg.add_theme_constant_override("margin_right",  16)
	mg.add_theme_constant_override("margin_top",    12)
	mg.add_theme_constant_override("margin_bottom", 16)
	col.add_child(mg)

	var content_col := VBoxContainer.new()
	content_col.add_theme_constant_override("separation", 10)
	mg.add_child(content_col)

	# ── Header row: [icon + title]  [stat number] ──
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 8)
	content_col.add_child(header_row)

	_add_icon_title(header_row, data.get("icon_char", "?"), data.get("title", ""), accent)

	# Spacer pushes stat to the right
	var hspacer := Control.new()
	hspacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(hspacer)

	_add_stat_block(header_row, data.get("stat_value", ""), data.get("stat_label", ""), accent)

	# ── Body row: [text column] [chart column] ──
	var body_row := HBoxContainer.new()
	body_row.add_theme_constant_override("separation", 14)
	content_col.add_child(body_row)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal   = Control.SIZE_EXPAND_FILL
	text_col.size_flags_stretch_ratio = 1.1
	text_col.add_theme_constant_override("separation", 7)
	body_row.add_child(text_col)

	# Body lines
	for line: String in data.get("body_lines", [] as Array):
		var lbl := Label.new()
		lbl.text = line
		lbl.add_theme_font_size_override("font_size", FS_BODY)
		lbl.add_theme_color_override("font_color", COLOR_TEXT_BODY)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_col.add_child(lbl)

	# Player-choice callout
	var callout: String = _get_choice_callout(data.get("choice_key", ""))
	if callout != "":
		var cl := Label.new()
		cl.text = "▶  Your choice:  " + callout
		cl.add_theme_font_size_override("font_size", FS_SPECIAL)
		cl.add_theme_color_override("font_color", COLOR_TEXT_SPECIAL)
		cl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_col.add_child(cl)

	# ★ Special text
	var special: String = data.get("special_text", "")
	if special != "":
		var sp := Label.new()
		sp.text = "★  " + special
		sp.add_theme_font_size_override("font_size", FS_SPECIAL)
		sp.add_theme_color_override("font_color", COLOR_TEXT_SPECIAL)
		sp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_col.add_child(sp)

	# ── Chart column ──
	var chart_col := VBoxContainer.new()
	chart_col.size_flags_horizontal   = Control.SIZE_EXPAND_FILL
	chart_col.size_flags_stretch_ratio = 0.75
	chart_col.alignment = BoxContainer.ALIGNMENT_CENTER
	chart_col.add_theme_constant_override("separation", 6)
	body_row.add_child(chart_col)

	var cdata: Array    = data.get("chart_data", [] as Array)
	var ctype: String   = data.get("chart_type", "pie")
	var chart: Control

	if ctype == "bar":
		chart = _make_bar_chart(cdata)
	else:
		chart = _make_pie_chart(cdata)

	chart_col.add_child(chart)
	_chart_nodes.append(chart)

	# Legend under chart
	chart_col.add_child(_make_legend(cdata))

	return panel


# ─────────────────────────────────────────────────────────────────
#  CARD SUB-ELEMENTS
# ─────────────────────────────────────────────────────────────────

# Icon box + title label, added into parent HBoxContainer
func _add_icon_title(parent: Control, icon: String, title: String, accent: Color) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	parent.add_child(hbox)

	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(40, 40)
	var bsty := StyleBoxFlat.new()
	bsty.bg_color = Color(accent.r, accent.g, accent.b, 0.14)
	bsty.set_corner_radius_all(9)
	bsty.set_border_width_all(2)
	bsty.border_color = Color(accent.r, accent.g, accent.b, 0.45)
	bsty.content_margin_left   = 4
	bsty.content_margin_right  = 4
	bsty.content_margin_top    = 2
	bsty.content_margin_bottom = 2
	box.add_theme_stylebox_override("panel", bsty)
	var icon_lbl := Label.new()
	icon_lbl.text = icon
	icon_lbl.add_theme_font_size_override("font_size", 22)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	box.add_child(icon_lbl)
	hbox.add_child(box)

	var h := Label.new()
	h.text = title
	h.add_theme_font_size_override("font_size", FS_HEADING)
	h.add_theme_color_override("font_color", COLOR_TEXT_HEADING)
	h.size_flags_vertical = Control.SIZE_FILL
	hbox.add_child(h)


# Stat number + label, added into parent HBoxContainer (aligns right)
func _add_stat_block(parent: Control, value: String, lbl_text: String, accent: Color) -> void:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 0)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(vb)

	var val_lbl := Label.new()
	val_lbl.text = value
	val_lbl.add_theme_font_size_override("font_size", FS_STAT)
	val_lbl.add_theme_color_override("font_color", accent)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vb.add_child(val_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = lbl_text
	sub_lbl.add_theme_font_size_override("font_size", FS_STAT_SUB)
	sub_lbl.add_theme_color_override("font_color", COLOR_TEXT_BODY)
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vb.add_child(sub_lbl)


# Colour dot + label rows under the chart
func _make_legend(cdata: Array) -> Control:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	for d: Dictionary in cdata:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 5)
		vb.add_child(row)

		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(9, 9)
		dot.color = d.get("color", Color.WHITE)
		# Center dot vertically
		var dot_wrap := Control.new()
		dot_wrap.custom_minimum_size = Vector2(9, 16)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		dot_wrap.add_child(dot)
		dot.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
		row.add_child(dot_wrap)

		var leg_lbl := Label.new()
		leg_lbl.text = d.get("label", "")
		leg_lbl.add_theme_font_size_override("font_size", 13)
		leg_lbl.add_theme_color_override("font_color", COLOR_TEXT_BODY)
		row.add_child(leg_lbl)
	return vb


# ─────────────────────────────────────────────────────────────────
#  CHART FACTORIES  (PieChartControl / BarChartControl are in
#  their own class_name scripts — no IDE nodes needed)
# ─────────────────────────────────────────────────────────────────

func _make_pie_chart(cdata: Array) -> Control:
	var ctrl := PieChartControl.new()
	ctrl.chart_data = cdata
	ctrl.bg_color   = COLOR_CHART_BG
	ctrl.custom_minimum_size   = Vector2(130, 130)
	ctrl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ctrl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	ctrl.set_meta("tooltip_panel", _tt_panel)
	return ctrl


func _make_bar_chart(cdata: Array) -> Control:
	var ctrl := BarChartControl.new()
	ctrl.chart_data = cdata
	ctrl.bg_color   = COLOR_CHART_BG
	ctrl.custom_minimum_size   = Vector2(150, 130)
	ctrl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ctrl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	ctrl.set_meta("tooltip_panel", _tt_panel)
	return ctrl


# ─────────────────────────────────────────────────────────────────
#  FOOTER
# ─────────────────────────────────────────────────────────────────

func _build_footer(parent: Control) -> void:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(hbox)

	var btn := Button.new()
	btn.text = "Return to Map  →"
	btn.custom_minimum_size = Vector2(320, 62)
	Stage.style_choice_button(btn, COLOR_TITLE_RULE)
	btn.add_theme_font_size_override("font_size", FS_BUTTON)
	hbox.add_child(btn)
	btn.pressed.connect(func() -> void: exit_requested.emit())


# ─────────────────────────────────────────────────────────────────
#  PLAYER-CHOICE TEXT  (reads from GameState.metrics)
# ─────────────────────────────────────────────────────────────────

func _get_choice_callout(key: String) -> String:
	match key:
		"land":
			if GameState.metrics.land_choice != null:
				return GameState.metrics.land_choice.value.capitalize()
		"electricity":
			if GameState.metrics.electricity_choice != null:
				return GameState.metrics.electricity_choice.value.capitalize() + " power source"
		"water":
			if GameState.metrics.water_choices.size() > 0:
				var picks: Array[String] = []
				for c: Metrics.ChoiceEntry in GameState.metrics.water_choices:
					picks.append(c.value.capitalize())
				return ", ".join(picks) + " river(s)"
	return ""


# ─────────────────────────────────────────────────────────────────
#  ANIMATION  (cards fade in staggered; charts spin/grow after)
# ─────────────────────────────────────────────────────────────────

func _animate_in() -> void:
	for i: int in _card_nodes.size():
		var card := _card_nodes[i]
		var tw := card.create_tween()
		tw.tween_interval(float(i) * CARD_STAGGER)
		tw.tween_property(card, "modulate:a", 1.0, FADE_DURATION)

	var chart_delay: float = float(_card_nodes.size()) * CARD_STAGGER + FADE_DURATION + 0.1
	for ch: Control in _chart_nodes:
		if ch.has_method("animate_in"):
			var ref := ch
			get_tree().create_timer(chart_delay).timeout.connect(
				func() -> void: ref.animate_in(), CONNECT_ONE_SHOT)
