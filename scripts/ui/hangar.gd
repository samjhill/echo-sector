extends Control

@onready var launch_button = $MainContainer/ActionSection/LaunchButton
@onready var ship_loadout_button = $MainContainer/ActionSection/ShipLoadoutButton
@onready var drone_panel = $MainContainer/ComingSoonSection/DronePanel
@onready var upgrade_panel = $MainContainer/ComingSoonSection/UpgradePanel
@onready var ship_loadout_panel = $ShipEquipmentScreen
@onready var build_label = $MainContainer/TopSection/TopRight/BuildLabel
@onready var credits_label = $MainContainer/TopSection/TopRight/CreditsLabel
@onready var scrap_label = $MainContainer/TopSection/TopRight/ScrapLabel

func _ready():
	PlayerData.load_game()
	build_label.text = "Build: " + BuildVersion.BUILD_VERSION + " - " + BuildVersion.BUILD_TIMESTAMP
	credits_label.text = "Credits: " + str(PlayerData.credits)
	scrap_label.text = "Scrap: " + str(PlayerData.scrap)
	
	# Connect button signals
	launch_button.pressed.connect(_on_launch_button_pressed)
	ship_loadout_button.pressed.connect(_on_ship_loadout_button_pressed)
	
	# Simple entrance animations
	_animate_ui_elements()

func _animate_ui_elements():
	# Start with all elements invisible
	launch_button.modulate.a = 0.0
	ship_loadout_button.modulate.a = 0.0
	drone_panel.modulate.a = 0.0
	upgrade_panel.modulate.a = 0.0
	
	# Animate them in with a slight delay
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(launch_button, "modulate:a", 1.0, 0.3).set_delay(0.1)
	tween.tween_property(ship_loadout_button, "modulate:a", 1.0, 0.3).set_delay(0.2)
	tween.tween_property(drone_panel, "modulate:a", 1.0, 0.3).set_delay(0.3)
	tween.tween_property(upgrade_panel, "modulate:a", 1.0, 0.3).set_delay(0.4)

func _on_launch_button_pressed():
	# Simple fade out before scene change
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/game/node_2d.tscn"))

func _on_ship_loadout_button_pressed():
	ship_loadout_panel.visible = true
	ship_loadout_panel.populate_equipment_screen()
	
	# Simple fade in for the equipment screen
	ship_loadout_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(ship_loadout_panel, "modulate:a", 1.0, 0.3)

func _on_equipment_screen_closed():
	ship_loadout_panel.visible = false

func _on_launch_game_pressed():
	# Check if player has proper equipment
	var has_weapon = false
	var has_engine = false
	
	for weapon in PlayerData.equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	for engine in PlayerData.equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	if not has_weapon or not has_engine:
		print("Please equip at least one weapon and one engine before launching!")
		return
	
	# If properly equipped, launch the game
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/game/node_2d.tscn"))
