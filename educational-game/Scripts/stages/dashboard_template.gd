extends Stage

@export_category("Global Dashboard Settings")
@export var background_color: Color = Color("bebce9ff")
@export var title_text: String = "Final Report"
@export var subtitle_text: String = "See how your choices, {name}, shaped the real-world impact of your datacenter."

@export_category("Panel 1: Land Usage")
@export var p1_title: String = "Land Usage"
@export var p1_description: String = "AI center campuses require a lot of land. While the main buildings range in size from 7-40 hectares, which corresponds to 10-55 football fields, the entire campus can span between 30 and 350 hectares, which corresponds to 30-500 football fields. They not only take up a lot of space, but also transform the land they occupy. Often, peri-urban and agricultural landscapes are used for these specialised industrial zones, which can result in the loss of productive farmland."
@export var p1_choice_text: String = "Choice text updates dynamically"

@export_category("Panel 2: Hardware")
@export var p2_title: String = "Hardware"
@export var p2_description: String = "Villagers noticed laptops and other electronics becoming more expensive. The same advanced chips powering your AI systems were driving up global demand. Producing these chips requires many rare metals, such as copper, silicon and cobalt, and the process requires many other resources, such as purified water. The smaller the chips, the more precise and pure the resources have to be. The chips used in AI centres are much more costly to produce than those used in general data centres."
@export var p2_choice_text: String = "You bought multiple servers from Joe's shop\nduring the game to expand your AI center."

@export_category("Panel 3: Users")
@export var p3_title: String = "Users"
@export var p3_description: String = " " # Left blank intentionally for your charts!
@export var p3_choice_text: String = "ChatGPT has approximately 800 million weekly users"

@export_category("Panel 4: Energy Usage")
@export var p4_title: String = "Energy Usage"
@export var p4_description: String = "As CEO, your expansion contributes to the rapidly growing global energy demand of AI infrastructure, which currently accounts for 15-20% of data center electricity consumption worldwide. Overall, AI systems consume enough energy each year to power approximately two to three and a half times the number of Swiss family households."
@export var p4_choice_text: String = "By redirecting energy towards the AI data center near Petalia, you have significantly reduced the amount of electricity available to local households."

@export_category("Panel 5: Water Usage")
@export var p5_title: String = "Water Usage"
@export var p5_description: String = "As a CEO, you are also responsible for the amount of water used by the ai center. Water is used not only to cool down buildings and hardware in the AI center, but also during chip manufacturing and by power plant facilities that supply AI centers with power. The daily water footprint of ai systems is between 850 million and 2 billion litres of water every day, which is equivalent to the daily consumption of 5 to 13 million people."
@export var p5_choice_text: String = "Choice text updates dynamically"

@export_category("Panel 6: Carbon and Air Pollution")
@export var p6_title: String = "Carbon and Air Pollution"
@export var p6_description: String = "AI systems can have a carbon footprint between 32 and 80 millions of tons CO2, which corresponds to the carbon footprint of New York City or to the emission per passenger of 30-70 million economy class flights from Zurich to New York.Some AI centers use gas power daily, which increases air pollution and greenhouse gas emissions. AI centers usually have backup generators too, such as diesel-fuelled ones. These generators release harmful substances such as fine particulate matter and nitrogen oxides into the air, which can lead to respiratory or heart disease."
@export var p6_choice_text: String = ""

@export_category("Panel 7: Noise Pollution")
@export var p7_title: String = "Noise Pollution"
@export var p7_description: String = "Another drawback of building an AI centre is noise pollution. Building them close to residential areas can cause health issues such as stress and sleep deprivation. Potential sources of noise include cooling systems, diesel generators and whirring fans. These noises can reach up to 105 decibels, which is as loud as a jet flying overhead.\nFor reference, here are some other decibel measurements for common noises: Vacuum cleaner (60-85 dBA), blender or food processor (80-90 dBA), snow blower (105 dBA), baby crying (110 dBA), car horn (110 dBA)."
@export var p7_choice_text: String = ""

# Node references (assign these in the editor)
@onready var title_label: Label = $CanvasLayer/MarginContainer/MainLayout/HeaderContainer/Title
@onready var subtitle_label: Label = $CanvasLayer/MarginContainer/MainLayout/HeaderContainer/Subtitle
@onready var background: ColorRect = $CanvasLayer/Background

func _ready() -> void:
	# Hide UI elements until stage starts if needed, or initialize values
	_apply_theme()

func _apply_theme() -> void:
	
	if background:
		background.color = background_color
	if title_label:
		title_label.text = title_text.replace("{name}", GameState.player_name)
	if subtitle_label:
		subtitle_label.text = subtitle_text.replace("{name}", GameState.player_name)
		
	# read global choices
	# LAND CHOICE (Checks the Enum in GameState)
	match GameState.land_location:
		GameState.LandLocation.FIRST:
			p1_choice_text = "You built your AI centre on land that includes farmland."
		GameState.LandLocation.SECOND:
			p1_choice_text = "You built your AI center close to Petalia."
		GameState.LandLocation.THIRD:
			p1_choice_text = "You built your AI centre on land that used to be a forest."
		GameState.LandLocation.FOURTH:
			p1_choice_text = "You built your AI center on land that includes farmland."
		_:
			p1_choice_text = "You built your AI center on land that includes farmland."
	
	# ENERGY CHOICE (Checks the string in GameState)
	if GameState.electricity_choice == "far":
		p4_choice_text = "By redirecting energy towards the AI data center, you have slightly reduced the amount of electricity available to Pontia."
	elif GameState.electricity_choice == "close":
		p4_choice_text = "By redirecting energy towards the AI data center near Petalia and Fontania, you have significantly reduced the amount of electricity available to local households."
		
	# WATER CHOICE 
	if GameState.metrics.water_choices.size() >= 2:
		var choice1 = GameState.metrics.water_choices[0].value
		var choice2 = GameState.metrics.water_choices[1].value
		
		if choice1 == "north" and choice2 == "north":
			p5_choice_text = "By installing two water pumps on the North river, you have left Pontia with almost no water resources."
		elif choice1 == "west" and choice2 == "west":
			p5_choice_text = "Although installing two water pumps on the West River did not remove water resources from the villages, the nearby forest will be affected."
		elif choice1 == "east" and choice2 == "east":
			p5_choice_text = "By installing two water pumps on the East river, you have left Fontania with almost no water resources."
		elif (choice1 == "north" and choice2 == "west") or (choice1 == "west" and choice2 == "north"):
			p5_choice_text = "By installing a water pump near Pontia, you reduced their water resources to a level that they will notice, but which they can still live with. The forest next to the west river will also be affected."
		elif (choice1 == "north" and choice2 == "east") or (choice1 == "east" and choice2 == "north"):
			p5_choice_text = "By installing a water pump near Pontia and Fontania, you reduced their water resources to a level that they will notice, but which they can still live with."
		elif (choice1 == "west" and choice2 == "east") or (choice1 == "east" and choice2 == "west"):
			p5_choice_text = "By installing a water pump near Fontania, you reduced their water resources to a level that they will notice, but which they can still live with. The forest next to the west river will also be affected."
	else:
		p5_choice_text = "By installing two water pumps on the East river, you have left Fontania with almost no water resources."
	
	
	var top = $CanvasLayer/MarginContainer/MainLayout/TopRow
	var mid = $CanvasLayer/MarginContainer/MainLayout/MiddleRow
	var main = $CanvasLayer/MarginContainer/MainLayout
	# 1. Land Panel
	top.get_node("LandPanel/MarginContainer/PanelVBox/TopRow/Label").text = p1_title
	top.get_node("LandPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p1_description
	top.get_node("LandPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p1_choice_text
	# 2. Hardware Panel
	top.get_node("HWPanel/MarginContainer/PanelVBox/TopRow/Label").text = p2_title
	top.get_node("HWPanel/MarginContainer/PanelVBox/MiddleRow/VBoxContainer/RichTextLabel").text = p2_description
	top.get_node("HWPanel/MarginContainer/PanelVBox/MiddleRow/VBoxContainer/ChoiceBox/MarginContainer/Label").text = p2_choice_text
	# 3. Users Panel
	top.get_node("UsersPanel/MarginContainer/PanelVBox/TopRow/Label").text = p3_title
	#top.get_node("UsersPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p3_description
	top.get_node("UsersPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p3_choice_text
	# 4. Energy Panel
	mid.get_node("EnergyPanel/MarginContainer/PanelVBox/TopRow/Label").text = p4_title
	mid.get_node("EnergyPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p4_description
	mid.get_node("EnergyPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p4_choice_text
	# 5. Water Panel
	mid.get_node("WaterPanel/MarginContainer/PanelVBox/TopRow/Label").text = p5_title
	mid.get_node("WaterPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p5_description
	mid.get_node("WaterPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p5_choice_text
	# 6. Carbon and Air Pollution Panel (directly under MainLayout now)
	main.get_node("AirPollutionPanel/MarginContainer/PanelVBox/TopRow/Label").text = p6_title
	main.get_node("AirPollutionPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p6_description
	#main.get_node("AirPollutionPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p6_choice_text
	# 7. Noise Pollution Panel (now in MiddleRow)
	mid.get_node("NoisePollutionPanel/MarginContainer/PanelVBox/TopRow/Label").text = p7_title
	mid.get_node("NoisePollutionPanel/MarginContainer/PanelVBox/MiddleRow/RichTextLabel").text = p7_description
	#mid.get_node("NoisePollutionPanel/MarginContainer/PanelVBox/ChoiceBox/MarginContainer/Label").text = p7_choice_text


func _stage_start() -> void:
	# Called when this stage becomes active (from your stage manager pattern)
	self.visible = true
	_apply_theme()

func _stage_end() -> void:
	self.visible = false
