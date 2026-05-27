extends CanvasLayer

signal exit_requested

const _SFX_SHOP_ENTER: AudioStream = preload("res://Assets/Music/SellingTonHello.mp3")
const _SFX_BUY: AudioStream = preload("res://Assets/Music/Cash Register Sound Effect.mp3")
const _SFX_WHOOSH: AudioStream = preload("res://Assets/Music/Transition - Sound Effect HD.mp3")

@export var _PORTRAIT: Texture2D = preload("res://Assets/scene_png/salesman.png")
@export var _SPEAKER: String = "Joe Sellington"
@export var _INTRO_TEXT: String = "Well well, look who walked in! Don't think I've had the pleasure — what was the name again? ...{name}? Ohhh, {name}... now THAT'S a fine name. Lucky for you, today I happen to be running a special for friends with such fine names. You need 5 server racks? I got the best prices in town... today, anyway. Heh heh. Just point at what you want."
@export var _EXIT_TEXT: String = "Pleasure doing business {name}! All 5 racks, sold. Did you notice how everything else got pricier while you shopped? Bet a smart one like you can work out why. Come back soon!"
@export_multiline var _DEVICE_AREA_TEXT: String = "Whoa {name}! Those are for the walk-in crowd. You came in for the server racks on the left. Heh. And I spot that company card... I got nothing against a little creative accounting, but I don't need anyone poking around my books. COMPLETELY legal business, mind you. Squeaky clean. Probably.. Soooo servers. On the left. Be a pal."

@onready var counter = $Counter
@onready var price_hikes = [
	$PriceHike,
	$PriceHike2,
	$PriceHike3,
	$PriceHike4
]
@onready var phone_labels = [
	$Price/PhonePrices/Label,
	$Price/PhonePrices/Label2,
	$Price/PhonePrices/Label3,
	$Price/PhonePrices/Label4
]
@onready var tablet_labels = [
	$Price/TabletPrices/Label11,
	$Price/TabletPrices/Label10
]
@onready var laptop_labels = [
	$Price/LaptopPrices/Label9,
	$Price/LaptopPrices/Label8
]
@onready var accessory_labels = [
	$Price/AsscessoryPrices/Label7,
	$Price/AsscessoryPrices/Label6,
	$Price/AsscessoryPrices/Label5
]
var phone_prices = [1000, 1200, 600, 800]
var tablet_prices = [550, 1350]
var laptop_prices = [2200, 1400]
var accessory_prices = [120, 67, 240]
var servers_bought = 0

@onready var _device_area: Panel = $DeviceArea

func _ready():
	for hike in price_hikes:
		hike.hide()
	pulse_buttons()
	update_counter()
	update_all_prices()
	_device_area.gui_input.connect(_on_device_area_input)
	_show_intro_dialogue()


func _on_device_area_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if Dialogue.is_active():
		return
	var opts := DialogueOptions.new()
	opts.dim = false
	opts.auto_close = true
	var text: String = _DEVICE_AREA_TEXT.replace("{name}", GameState.player_name)
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, text, opts, _SFX_SHOP_ENTER)

func _get_buy_buttons() -> Array:
	return [$BuyServerButtons/Button]

func _set_buy_buttons_enabled(enabled: bool) -> void:
	for btn in _get_buy_buttons():
		btn.disabled = !enabled

func _show_intro_dialogue() -> void:
	_set_buy_buttons_enabled(false)
	Dialogue.on_typewriter_done.connect(func(): _show_action_button("Start Shopping  ->", _on_start_pressed), CONNECT_ONE_SHOT)
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = false
	var text: String = _INTRO_TEXT.replace("{name}", GameState.player_name)
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, text, opts, _SFX_SHOP_ENTER)

func _show_exit_dialogue() -> void:
	_set_buy_buttons_enabled(false)
	Dialogue.on_typewriter_done.connect(func(): _show_action_button("Return to Map  ->", _on_return_pressed), CONNECT_ONE_SHOT)
	var opts := DialogueOptions.new()
	opts.dim = true
	opts.auto_close = false
	var text: String = _EXIT_TEXT.replace("{name}", GameState.player_name)
	Dialogue.show_dialogue(_PORTRAIT, _SPEAKER, text, opts,  _SFX_SHOP_ENTER)


func _show_action_button(text: String, on_pressed: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(360, 80)
	Stage.style_choice_button(btn, Color(1.0, 0.7, 0.2, 1.0))

	Dialogue.mount_choices([btn])

	Stage.pulse_choice_buttons([btn])
	var pulse_timer := Timer.new()
	pulse_timer.wait_time = 3.0
	pulse_timer.autostart = true
	pulse_timer.timeout.connect(func(): Stage.pulse_choice_buttons([btn]))
	btn.add_child(pulse_timer)

	btn.pressed.connect(func():
		MusicManager.play_sfx(_SFX_WHOOSH)
		btn.disabled = true
		pulse_timer.stop()
		var fade := btn.create_tween()
		fade.tween_property(btn, "modulate:a", 0.0, 0.35)
		await fade.finished
		Dialogue.dismiss()
		on_pressed.call()
	)


func _on_start_pressed() -> void:
	_set_buy_buttons_enabled(true)

func _on_return_pressed() -> void:
	exit_requested.emit()


func update_counter():
	counter.text = "%d/5" % servers_bought

func update_all_prices():
	for i in range(phone_prices.size()):
		phone_labels[i].text = "$" + str(phone_prices[i])
	for i in range(tablet_prices.size()):
		tablet_labels[i].text = "$" + str(tablet_prices[i])
	for i in range(laptop_prices.size()):
		laptop_labels[i].text = "$" + str(laptop_prices[i])
	for i in range(accessory_prices.size()):
		accessory_labels[i].text = "$" + str(accessory_prices[i])

func raise_prices():
	for i in range(phone_prices.size()):
		phone_prices[i] += randi_range(50, 200)
	for i in range(tablet_prices.size()):
		tablet_prices[i] += randi_range(100, 400)
	for i in range(laptop_prices.size()):
		laptop_prices[i] += randi_range(100, 500)
	for i in range(accessory_prices.size()):
		accessory_prices[i] += randi_range(10, 30)
	update_all_prices()

func pulse_buttons():
	var buttons = [$BuyServerButtons/Button]
	for button in buttons:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(button, "modulate", Color(1.267, 0.698, 1.432, 1.0), 1)
		tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 1)

func show_price_hikes():
	for hike in price_hikes:
		hike.show()

func buy_server():
	MusicManager.play_sfx(_SFX_BUY)
	servers_bought += 1
	update_counter()
	raise_prices()
	if servers_bought == 1:
		show_price_hikes()
	if servers_bought >= 5:
		_show_exit_dialogue()

func _on_button_pressed():
	buy_server()
