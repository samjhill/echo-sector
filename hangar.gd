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
	load_equipment_from_player_data()

func _on_launch_pressed():
	# Replace with your actual Abyss run scene path
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_ship_loadout_button_pressed():
	print("toggle visibility of equipment screen")
	ship_loadout_panel.visible = !ship_loadout_panel.visible
	logo.visible = !logo.visible

func load_equipment_from_player_data():
	var equipped_components = PlayerData.equipped_components
	for slot_name in equipped_components:
		print("loading ", slot_name)
		var component = equipped_components[slot_name]
		print("component for slot: ", component)
		update_slot_ui(slot_name, component)

func update_slot_ui(slot_name: String, component: Dictionary):
	# Update UI elements (e.g., icon, name)
	var slot_node
	var node_name
	if slot_name == "weapon":
		node_name = "ShipEquipmentScreen/Panel/VBoxContainer/WeaponSlots/"
		slot_node = get_node(node_name + "Slot1")
	
	if slot_name == "engine":
		node_name = "ShipEquipmentScreen/Panel/VBoxContainer/EngineSlot"
		slot_node = get_node(node_name)
	
	#slot_node.get_node("Icon").texture = load(component.icon_path)
	print("slot_name:", node_name)
	print("slot_node: ", slot_node)
	slot_node.get_node("Label").text = component.name

func save_equipment_to_player_data():
	var equipped = {}
	for slot in ["engine", "weapon", "shield"]:  # Customize for your slots
		var slot_node = get_node("SlotContainer/" + slot)
		var component = {
			"name": slot_node.get_node("Label").text,
			"icon_path": slot_node.get_node("Icon").texture.resource_path,
			"type": slot  # optional
		}
		equipped[slot] = component
	
	PlayerData.equipped_components = equipped
	PlayerData.save_game()
