extends Camera2D

@export var speed: float = 1500.0
@export var zoom_min: float = 0.2
@export var zoom_max: float = 2.0
@export var zoom_step: float = 1.1

var _dragging: bool = false


func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	if direction != Vector2.ZERO:
		var new_pos = position + (direction * speed * delta)
		position = _clamp_pos(new_pos)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Zoom in
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_change_zoom(zoom_step)
		# Zoom out
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_change_zoom(1.0 / zoom_step)
		# Dragging
		elif event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
	elif event is InputEventMouseMotion and _dragging:
		position = _clamp_pos(position - event.relative / zoom.x)


func _change_zoom(factor: float) -> void:
	var new_zoom: float = clamp(zoom.x * factor, zoom_min, zoom_max)
	zoom = Vector2(new_zoom, new_zoom)
	position = _clamp_pos(position)


func _clamp_pos(p: Vector2) -> Vector2:
	var viewport_size = get_viewport_rect().size / zoom
	var half_view = viewport_size / 2
	p.x = clamp(p.x, limit_left + half_view.x, limit_right - half_view.x)
	p.y = clamp(p.y, limit_top + half_view.y, limit_bottom - half_view.y)
	return p
