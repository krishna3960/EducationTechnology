extends Stage

const SHOP_SCENE = preload("res://Scenes/Shop.tscn")
var _shop

func _stage_start() -> void:
	_shop = SHOP_SCENE.instantiate()
	add_child(_shop)
	_shop.exit_requested.connect(func(): finished.emit())

func _stage_end() -> void:
	if _shop:
		_shop.queue_free()
