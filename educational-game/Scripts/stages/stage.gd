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
