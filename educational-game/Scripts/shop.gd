extends CanvasLayer
@onready var dim_overlay = $"Intro PopUp/DimOverLay"
@onready var color_rect = $"Intro PopUp/ColorRect"
@onready var label = $"Intro PopUp/LabelExpl1"
@onready var label2 = $"Intro PopUp/LabelExpl2"
@onready var button4 = $"Intro PopUp/Button4"
@onready var counter = $Counter
# Exit popup
@onready var exit_popup_dim = $"Exit Pop Up/DimOverLay2"
@onready var exit_popup_rect = $"Exit Pop Up/ColorRect2"
@onready var exit_label3 = $"Exit Pop Up/LabelExpl3"
@onready var exit_label4 = $"Exit Pop Up/LabelExpl4"
@onready var exit_button = $"Exit Pop Up/Button5"
# Price hikes
@onready var price_hikes = [
	$PriceHike,
	$PriceHike2,
	$PriceHike3,
	$PriceHike4
]
# Phone price labels
@onready var phone_labels = [
	$Price/PhonePrices/Label,
	$Price/PhonePrices/Label2,
	$Price/PhonePrices/Label3,
	$Price/PhonePrices/Label4
]
# Tablet price labels
@onready var tablet_labels = [
	$Price/TabletPrices/Label11,
	$Price/TabletPrices/Label10
]
# Laptop price labels
@onready var laptop_labels = [
	$Price/LaptopPrices/Label9,
	$Price/LaptopPrices/Label8
]
# Accessory price labels
@onready var accessory_labels = [
	$Price/AsscessoryPrices/Label7,
	$Price/AsscessoryPrices/Label6,
	$Price/AsscessoryPrices/Label5
]
# Starting prices
var phone_prices = [1000, 1200, 600, 800]
var tablet_prices = [550, 1350]
var laptop_prices = [2200, 1400]
var accessory_prices = [120, 67, 240]
var servers_bought = 0

func _ready():
	dim_overlay.show()
	color_rect.show()
	label.show()
	label2.show()
	button4.show()
	# Hide exit popup at start
	exit_popup_dim.hide()
	exit_popup_rect.hide()
	exit_label3.hide()
	exit_label4.hide()
	exit_button.hide()
	pulse_buttons()
	# Hide price hikes at start
	for hike in price_hikes:
		hike.hide()
	update_counter()
	update_all_prices()

func update_counter():
	counter.text = str(servers_bought)

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
	var buttons = [$BuyServerButtons/Button, $BuyServerButtons/Button2, $BuyServerButtons/Button3]
	for button in buttons:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(button, "modulate", Color(1.267, 0.698, 1.432, 1.0), 1)
		tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 1)

func show_price_hikes():
	for hike in price_hikes:
		hike.show()

func show_exit_popup():
	exit_popup_dim.show()
	exit_popup_rect.show()
	exit_label3.show()
	exit_label4.show()
	exit_button.show()

func buy_server():
	servers_bought += 1
	update_counter()
	raise_prices()
	if servers_bought == 1:
		show_price_hikes()
	if servers_bought >= 5:
		show_exit_popup()

func _on_button_4_pressed():
	dim_overlay.hide()
	color_rect.hide()
	label.hide()
	label2.hide()
	button4.hide()

func _on_button_pressed():
	buy_server()

func _on_button_2_pressed():
	buy_server()

func _on_button_3_pressed():
	buy_server()

func _on_button_5_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
