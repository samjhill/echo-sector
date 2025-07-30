extends Control

@onready var launch_button = $MainContainer/ActionSection/LaunchButton
@onready var ship_loadout_button = $MainContainer/ActionSection/ShipLoadoutButton
@onready var stellar_grid_button = $MainContainer/ActionSection/StellarGridButton
@onready var settings_button = $MainContainer/ActionSection/SettingsButton
@onready var drone_panel = $MainContainer/ComingSoonSection/DronePanel
@onready var upgrade_panel = $MainContainer/ComingSoonSection/UpgradePanel
@onready var ship_loadout_panel = $ShipEquipmentScreen
@onready var settings_panel = $SettingsScreen
var stellar_grid_panel: Control = null
@onready var build_label = $MainContainer/TopSection/TopRight/BuildLabel
@onready var credits_label = $MainContainer/TopSection/TopRight/CreditsLabel
@onready var scrap_label = $MainContainer/TopSection/TopRight/ScrapLabel

func _ready():
	PlayerData.load_game()
	update_ui_display()
	
	# Connect button signals
	launch_button.pressed.connect(_on_launch_button_pressed)
	ship_loadout_button.pressed.connect(_on_ship_loadout_button_pressed)
	stellar_grid_button.pressed.connect(_on_stellar_grid_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	
	# Connect to PlayerData signals for dynamic updates
	PlayerData.credits_changed.connect(_on_credits_changed)
	PlayerData.scrap_changed.connect(_on_scrap_changed)
	
	# Simple entrance animations
	_animate_ui_elements()

func _animate_ui_elements():
	# Start with all elements invisible
	launch_button.modulate.a = 0.0
	ship_loadout_button.modulate.a = 0.0
	stellar_grid_button.modulate.a = 0.0
	drone_panel.modulate.a = 0.0
	upgrade_panel.modulate.a = 0.0
	
	# Animate them in with a slight delay
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(launch_button, "modulate:a", 1.0, 0.3).set_delay(0.1)
	tween.tween_property(ship_loadout_button, "modulate:a", 1.0, 0.3).set_delay(0.2)
	tween.tween_property(stellar_grid_button, "modulate:a", 1.0, 0.3).set_delay(0.3)
	tween.tween_property(drone_panel, "modulate:a", 1.0, 0.3).set_delay(0.4)
	tween.tween_property(upgrade_panel, "modulate:a", 1.0, 0.3).set_delay(0.5)

func _on_launch_button_pressed():
	"""Launch button pressed - check equipment and launch game"""
	# Check if player has proper equipment
	var has_weapon = false
	var has_engine = false
	
	var equipped_weapons = PlayerData.get_equipped_weapons()
	for weapon in equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	var equipped_engines = PlayerData.get_equipped_engines()
	for engine in equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	if not has_weapon or not has_engine:
		Logger.warning("Please equip at least one weapon and one engine before launching!", "Hangar")
		# Open the equipment screen to help the player equip items
		_open_equipment_screen_for_missing_equipment()
		return
	
	# Launch the game with fade out
	Logger.info("Launching game with equipment validation passed", "Hangar")
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

func _open_equipment_screen_for_missing_equipment():
	"""Open the equipment screen with notification about missing equipment"""
	ship_loadout_panel.visible = true
	ship_loadout_panel.populate_equipment_screen(true)  # Show missing equipment notification
	
	# Simple fade in for the equipment screen
	ship_loadout_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(ship_loadout_panel, "modulate:a", 1.0, 0.3)

func _on_stellar_grid_button_pressed():
	if stellar_grid_panel == null:
		stellar_grid_panel = preload("res://scenes/ui/stellar_grid_screen.tscn").instantiate()
		add_child(stellar_grid_panel)
		# Connect to close event
		stellar_grid_panel.visibility_changed.connect(_on_stellar_grid_visibility_changed)
	
	stellar_grid_panel.visible = true
	
	# Simple fade in for the stellar grid screen
	stellar_grid_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(stellar_grid_panel, "modulate:a", 1.0, 0.3)

func _on_settings_button_pressed():
	"""Handle settings button press"""
	Logger.info("Settings button pressed", "Hangar")
	
	if settings_panel == null:
		Logger.error("Settings panel is null!", "Hangar")
		return
	
	Logger.info("Settings panel found, making visible", "Hangar")
	settings_panel.visible = true
	
	# Simple fade in for the settings screen
	settings_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(settings_panel, "modulate:a", 1.0, 0.3)
	
	Logger.info("Settings panel visibility: %s" % settings_panel.visible, "Hangar")

func _on_equipment_screen_closed():
	ship_loadout_panel.visible = false

func _on_stellar_grid_visibility_changed():
	if stellar_grid_panel != null and not stellar_grid_panel.visible:
		# Grid screen was closed, we can clean up if needed
		pass

# Removed duplicate _on_launch_game_pressed() function - using _on_launch_button_pressed() instead

func update_ui_display():
	"""Update all UI elements with current data"""
	build_label.text = "Build: " + BuildVersion.BUILD_VERSION + " - " + BuildVersion.BUILD_TIMESTAMP
	credits_label.text = "Credits: " + str(PlayerData.credits)
	scrap_label.text = "Scrap: " + str(PlayerData.scrap)

func _on_credits_changed(new_amount: int):
	"""Handle credits change with animation"""
	credits_label.text = "Credits: " + str(new_amount)
	_animate_value_change(credits_label)

func _on_scrap_changed(new_amount: int):
	"""Handle scrap change with animation"""
	scrap_label.text = "Scrap: " + str(new_amount)
	_animate_value_change(scrap_label)

func _animate_value_change(label: Label):
	"""Animate a label when its value changes"""
	# Create a subtle scale animation
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale up slightly
	tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(label, "modulate", Color.YELLOW, 0.1)
	
	# Scale back down
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1)
	tween.tween_property(label, "modulate", Color.WHITE, 0.2).set_delay(0.1)
