extends TileMapLayer

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var cell = local_to_map(to_local(mouse_pos))
		print("Clicked tile:", cell)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
@onready var tilemap = $"../MiddleLayer"
func change_tile(cell: Vector2i, atlas_coords: Vector2i, source_id: int = 0):
	tilemap.set_cell(cell, source_id, atlas_coords)
