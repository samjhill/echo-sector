extends Control

@onready var ship_loadout_button = $MainContainer/CenterSection/ShipLoadoutButton
@onready var ship_loadout_panel = $ShipEquipmentScreen
@onready var logo = $MainContainer/TopSection/Logo
@onready var credits_label = $MainContainer/TopSection/TopRight/CreditsLabel
@onready var scrap_label = $MainContainer/TopSection/TopRight/ScrapLabel
@onready var build_label = $MainContainer/TopSection/TopRight/BuildLabel

func _ready():
	PlayerData.load_game()
	build_label.text = "Build: " + BuildVersion.BUILD_VERSION + " - " + BuildVersion.BUILD_TIMESTAMP
	# Update labels with current data
	credits_label.text = "Credits: " + str(PlayerData.credits)
	scrap_label.text = "Scrap: " + str(PlayerData.scrap)
	
	# Connect button signals
	ship_loadout_button.pressed.connect(_on_ship_loadout_button_pressed)
	
	# Connect launch button
	var launch_button = $MainContainer/CenterSection/LaunchButton
	launch_button.pressed.connect(_on_launch_button_pressed)

func _on_ship_loadout_button_pressed():
	ship_loadout_panel.visible = true
	ship_loadout_panel.populate_equipment_screen()

func _on_launch_button_pressed():
	get_tree().change_scene_to_file("res://node_2d.tscn")
