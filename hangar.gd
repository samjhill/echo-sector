extends Control

@onready var ship_loadout_button = $VBoxContainer/ShipLoadoutButton
@onready var ship_loadout_panel = $ShipEquipmentScreen
@onready var logo = $Logo

func _ready():
	PlayerData.load_game()
	$VBoxContainer/BuildLabel.text = "Build: " + BuildVersion.BUILD_VERSION + " - " + BuildVersion.BUILD_TIMESTAMP
	$VBoxContainer/CreditsLabel.text = "Credits: " + str(PlayerData.credits)
	$VBoxContainer/ScrapLabel.text = "Scrap: " + str(PlayerData.scrap)

	$VBoxContainer/LaunchButton.pressed.connect(_on_launch_pressed)
	
	print("Button found:", ship_loadout_button)
	ship_loadout_button.pressed.connect(_on_ship_loadout_button_pressed)
	load_equipment_from_player_data()

func _on_launch_pressed():
	# Check if player has a weapon and engine equipped
	var equipped = PlayerData.equipped_components
	var has_weapon = equipped.has("weapon")
	var has_engine = equipped.has("engine")
	if not has_weapon or not has_engine:
		print("Player missing equipment! Routing to equipment screen.")
		ship_loadout_panel.visible = true
		logo.visible = false
		return
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
		var components = equipped_components[slot_name]  # This is now an array
		print("components for slot: ", components)
		update_slot_ui(slot_name, components)

func update_slot_ui(slot_name: String, components: Array):
	# Update UI elements for multiple components per slot
	if slot_name == "weapon":
		for i in range(components.size()):
			var component = components[i]
			var slot_node = get_node("ShipEquipmentScreen/Panel/VBoxContainer/WeaponSlots/Slot" + str(i + 1))
			if slot_node and component != null:
				slot_node.get_node("Label").text = component.name
				if component.icon:
					slot_node.get_node("TextureRect").texture = component.icon
	
	if slot_name == "engine":
		for i in range(components.size()):
			var component = components[i]
			var slot_node = get_node("ShipEquipmentScreen/Panel/VBoxContainer/EngineSlot" + str(i + 1))
			if slot_node and component != null:
				slot_node.get_node("Label").text = component.name
				if component.icon:
					slot_node.get_node("TextureRect").texture = component.icon

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
