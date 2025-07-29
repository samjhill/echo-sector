extends Control

@onready var ship_loadout_button = $MainContainer/ActionSection/ShipLoadoutButton
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
	var launch_button = $MainContainer/ActionSection/LaunchButton
	launch_button.pressed.connect(_on_launch_button_pressed)

func _on_ship_loadout_button_pressed():
	ship_loadout_panel.visible = true
	ship_loadout_panel.populate_equipment_screen()

func _on_launch_button_pressed():
	# Check if player has proper equipment
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.equipped_components.get("engine", [])
	
	# Check if player has at least one weapon and one engine
	var has_weapon = equipped_weapons.size() > 0 and equipped_weapons[0] != null
	var has_engine = equipped_engines.size() > 0 and equipped_engines[0] != null
	
	if not has_weapon or not has_engine:
		# Route to equipment screen if missing equipment
		ship_loadout_panel.visible = true
		ship_loadout_panel.populate_equipment_screen()
		return
	
	# If properly equipped, launch the game
	get_tree().change_scene_to_file("res://node_2d.tscn")
