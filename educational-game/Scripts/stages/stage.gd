class_name Stage
extends Node2D

##  This is the abstract class for a Stage. Each stage should extend this and implement _stage_start() and _stage_end(). When the stage is finished, it should emit the "finished" signal, which will cause the StageManager to advance to the next stage.


## When this signal is emitted, the stage manager will advance to the next stage and call _stage_end. Emit this when the stage is finished.
signal finished

## The stage manager calls this method once when the stage starts.
func _stage_start() -> void:
	pass

## The stage manager calls this method once when the stage ends (i.e after finished.emit())
func _stage_end() -> void:
	pass


## Shared styling for the prev/next/choose buttons used during stage dialogues.
static func style_choice_button(btn: Button, accent: Color) -> void:
	var make_sb := func(bg: Color, border: Color) -> StyleBoxFlat:
		var sb := StyleBoxFlat.new()
		sb.bg_color = bg
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(4)
		sb.border_color = border
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
		return sb
	var bg := Color(0.08, 0.10, 0.15, 0.92)
	var bg_hover := Color(0.30, 0.36, 0.48, 0.97)
	var bg_pressed := Color(0.05, 0.06, 0.10, 0.95)
	btn.add_theme_stylebox_override("normal", make_sb.call(bg, accent))
	btn.add_theme_stylebox_override("hover", make_sb.call(bg_hover, Color(accent.r, accent.g, accent.b, min(accent.a + 0.4, 1.0))))
	btn.add_theme_stylebox_override("pressed", make_sb.call(bg_pressed, accent))
	btn.add_theme_stylebox_override("focus", make_sb.call(bg, accent))
	btn.add_theme_color_override("font_color", Color(0.96, 0.96, 0.96))
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color(0.85, 0.85, 0.85))
	btn.add_theme_font_size_override("font_size", 22)


## Fades each button in  over `duration` seconds.
static func fade_in_choice_buttons(buttons: Array, duration: float = 0.35) -> void:
	for btn in buttons:
		if btn == null:
			continue
		btn.modulate.a = 0.0
		var t : Tween = btn.create_tween()
		t.tween_property(btn, "modulate:a", 1.0, duration)


## Disables/enables the Camera such that the player can't pan with WASD or zoom with the mouse wheel underneath it.
static func set_world_camera_enabled(enabled: bool) -> void:
	if MapLayer.main == null:
		return
	var cam: Camera2D = MapLayer.main.get_parent().get_node_or_null("Camera2D")
	if cam == null:
		return
	cam.set_process(enabled)
	cam.set_process_unhandled_input(enabled)


## Plays a repeating "look at me" pulse on each button
static func pulse_choice_buttons(buttons: Array, iterations: int = 6, gap: float = 1.4) -> void:
	const startdelay: float = 0.5
	const hold: float = 0.26
	const stagger: float = 0.40
	for i in buttons.size():
		var btn: Button = buttons[i]
		if btn == null:
			continue
		var t := btn.create_tween()
		t.tween_interval(startdelay + stagger * i)
		for iter in iterations:
			t.tween_callback(func() -> void:
				var prev_normal: StyleBox = btn.get_theme_stylebox("normal")
				var hover_style: StyleBox = btn.get_theme_stylebox("hover")
				if prev_normal == null or hover_style == null:
					return
				btn.set_meta("_pulse_prev_normal", prev_normal)
				btn.add_theme_stylebox_override("normal", hover_style))
			t.tween_interval(hold)
			t.tween_callback(func() -> void:
				var prev: StyleBox = btn.get_meta("_pulse_prev_normal", null) as StyleBox
				if prev:
					btn.add_theme_stylebox_override("normal", prev)
					btn.remove_meta("_pulse_prev_normal"))
			if iter < iterations - 1:
				t.tween_interval(gap)
