extends Camera2D

@export var speed: float = 1500.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	var viewport_size = get_viewport_rect().size / zoom
	var half_view = viewport_size / 2
	var new_pos = position + (direction * speed * delta)
	
	new_pos.x = clamp(new_pos.x, -325 , limit_right - half_view.x)
	new_pos.y = clamp(new_pos.y, -315 , limit_bottom - half_view.y)
	position = new_pos
