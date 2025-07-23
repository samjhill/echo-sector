extends Node

var credits: int = 0
#var unlocked_ships: Array[StringName] = []
var inventory: Array = []
var equipped_components: Dictionary = {}

const SAVE_FILE_PATH := "user://save_data.json"

func _ready():
	var test_item = {
		"name": "Plasma Core",
		"description": "Used in advanced weaponry",
		"icon_path": "res://items/plasma-core.png"
	}
	test_item["icon"] = load(test_item["icon_path"])
	inventory.append(test_item)

func save_game():
	var serialized_inventory = []
	for item in inventory:
		serialized_inventory.append({
			"name": item.get("name", ""),
			"description": item.get("description", ""),
			"icon_path": item.get("icon_path", "")
		})

	var data = {
		"credits": credits,
		#"unlocked_ships": unlocked_ships,
		"inventory": serialized_inventory
	}

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found.")
		return

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var result = JSON.parse_string(content)
	if result is Dictionary:
		credits = result.get("credits", 0)
		#unlocked_ships = result.get("unlocked_ships", [])
		
		inventory.clear()
		var starter_items = [
			{
			  "name": "Pulse Laser Mk I",
			  "description": "Entry-level laser cannon",
			  "slot_type": "weapon",
			  "icon_path": "res://items/pulse_laser.png"
			},
			{
				"name": "Basic Thruster",
				"description": "Reliable but slow thruster to get you around.",
				"slot_type": "engine",
				"thrust": 200.0,
				"maneuverability": 0.8,
				"icon_path": "res://items/basic_thruster.png"
			}
		]
		var loaded_inventory = result.get("inventory", starter_items)
		for item_data in loaded_inventory:
			var item = {
				"name": item_data.get("name", ""),
				"description": item_data.get("description", ""),
				"icon_path": item_data.get("icon_path", ""),
				"icon": null
			}
			if item["icon_path"] != "":
				item["icon"] = load(item["icon_path"])
			inventory.append(item)
			
		var loaded_equipment = result.get("equipment", starter_items)
		for item in loaded_equipment:
			var slot_type = item["slot_type"]
			equipped_components[slot_type] = item
			if item["icon_path"] != "":
				item["icon"] = load(item["icon_path"])
				
			
		
