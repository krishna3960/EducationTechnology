# Renders a newspaper article centered on screen with an entrance/exit animation.
extends Node

enum Article {
	FARMLAND,
	FOREST,
	VILLAGE_TOO_CLOSE,
	INSOMNIA,
	SCIENTIST,
	WATER_CRISIS,
	WINTER,
	FISH,
	PRICES_LAPTOPS,
}

const _TEXTURES: Dictionary = {
	Article.FARMLAND: preload("res://Assets/scene_png/newspapers/newspaper-farmland.png"),
	Article.FOREST: preload("res://Assets/scene_png/newspapers/newspaper-forest.png"),
	Article.VILLAGE_TOO_CLOSE: preload("res://Assets/scene_png/newspapers/newspaper-landTooClose.png"),
	Article.INSOMNIA: preload("res://Assets/scene_png/newspapers/newspaper-insomnia.png"),
	Article.SCIENTIST: preload("res://Assets/scene_png/newspapers/newspaper-scientist.png"),
	Article.WATER_CRISIS: preload("res://Assets/scene_png/newspapers/newspaper-waterCrisis.png"),
	Article.WINTER: preload("res://Assets/scene_png/newspapers/newspaper-winter.png"),
	Article.FISH: preload("res://Assets/scene_png/newspapers/newspaper-fish.png"),
	Article.PRICES_LAPTOPS: preload("res://Assets/scene_png/newspapers/newspaper-pricesLaptops.png"),
}

const DIM_ALPHA: float = 0.6
const ENTRANCE_DURATION: float = 0.55
const EXIT_DURATION: float = 0.25
const ENTRANCE_ROTATION: float = -0.6  # ~-34° CCW

# Emitted when the article is dismissed.
signal on_close

@onready var _ui: Control = $UILayer/Container
@onready var _paper: TextureRect = $UILayer/Container/Paper
@onready var _dim_rect: ColorRect = $DimLayer/DimRect
@onready var _dim_layer: CanvasLayer = $DimLayer
@onready var _ui_layer: CanvasLayer = $UILayer

var _active: bool = false
var _tween: Tween


func _ready() -> void:
	_dim_layer.layer = RenderLayers.NEWSPAPER_DIM
	_ui_layer.layer = RenderLayers.NEWSPAPER_UI
	_ui.visible = false
	_dim_rect.modulate.a = 0.0
	_dim_rect.visible = false
	if OS.is_debug_build():
		var section: VBoxContainer = Debug.add_section("Newspaper")
		Debug.add_option(Article.keys(), -1, func(idx): show_article(idx), section)


## Show a newspaper article. The article is dismissed on click.
func show_article(article: Article) -> void:
	if _active:
		return
	if not _TEXTURES.has(article):
		push_error("Newspaper: unknown article %s" % article)
		return
	_paper.texture = _TEXTURES[article]
	_ui.visible = true
	_dim_rect.visible = true
	_active = true
	EventLogger.record("newspaper_show", {"article": Article.keys()[article]})
	_animate_in()


## Close the article.
func dismiss() -> void:
	if _active:
		_close()


func _animate_in() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_paper.pivot_offset = _paper.size / 2.0
	_paper.scale = Vector2(0.05, 0.05)
	_paper.rotation = ENTRANCE_ROTATION
	_dim_rect.modulate.a = 0.0
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_dim_rect, "modulate:a", DIM_ALPHA, ENTRANCE_DURATION * 0.6)
	_tween.tween_property(_paper, "scale", Vector2(1.0, 1.0), ENTRANCE_DURATION) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_paper, "rotation", 0.0, ENTRANCE_DURATION) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _close() -> void:
	if not _active:
		return
	_active = false
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_paper, "scale", Vector2(0.05, 0.05), EXIT_DURATION)
	_tween.tween_property(_paper, "rotation", -ENTRANCE_ROTATION, EXIT_DURATION)
	_tween.tween_property(_dim_rect, "modulate:a", 0.0, EXIT_DURATION)
	_tween.chain().tween_callback(_finalize_close)


func _finalize_close() -> void:
	_ui.visible = false
	_dim_rect.visible = false
	EventLogger.record("newspaper_close")
	on_close.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	var advance: bool = (event is InputEventMouseButton and event.pressed) \
		or event.is_action_pressed("ui_accept") \
		or event.is_action_pressed("ui_cancel")
	if not advance:
		return
	get_viewport().set_input_as_handled()
	_close()
