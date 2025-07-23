extends Control

@onready var ship_loadout_button = $VBoxContainer/ShipLoadoutButton
@onready var ship_loadout_panel = $ShipEquipmentScreen
@onready var logo = $Logo

func _ready():
	PlayerData.load_game()
	$VBoxContainer/BuildLabel.text = "Build: " + BuildVersion.BUILD_VERSION + " - " + BuildVersion.BUILD_TIMESTAMP
	$VBoxContainer/CreditsLabel.text = "Credits: " + str(PlayerData.credits)

	$VBoxContainer/LaunchButton.pressed.connect(_on_launch_pressed)
	
	print("Button found:", ship_loadout_button)
	ship_loadout_button.pressed.connect(_on_ship_loadout_button_pressed)

func _on_launch_pressed():
	# Replace with your actual Abyss run scene path
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_ship_loadout_button_pressed():
	print("toggle visibility of equipment screen")
	ship_loadout_panel.visible = !ship_loadout_panel.visible
	logo.visible = !logo.visible
