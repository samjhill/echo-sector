extends Node

var credits: int = 0
var scrap: int = 0
var inventory: Array = []
var equipped_components: Dictionary = {}

const SAVE_FILE_PATH := "user://save_data.json"

func _ready():
	# Start with empty inventory for new players
	pass

func save_game():
	var serialized_inventory = []
	for item in inventory:
		if item != null:
			serialized_inventory.append({
				"name": item.name,
				"description": item.description,
				"icon_path": item.icon_path,
				"slot_type": item.slot_type,
				"stats": item.stats,
				"resource_path": "res://item.gd"  # Default resource path
			})
		else:
			print("Warning: Found null item in inventory during save")
	var serialized_equipment = {}
	for slot in equipped_components:
		var items = equipped_components[slot]
		if typeof(items) == TYPE_ARRAY:
			serialized_equipment[slot] = []
			for item in items:
				if item != null:
					serialized_equipment[slot].append({
						"name": item.name,
						"description": item.description,
						"icon_path": item.icon_path,
						"slot_type": item.slot_type,
						"stats": item.stats,
						"resource_path": "res://item.gd"  # Default resource path
					})
				else:
					print("Warning: Found null item in equipped_components[", slot, "] during save")
		else:
			# Backward compatibility: single item
			if items != null:
				serialized_equipment[slot] = [{
					"name": items.name,
					"description": items.description,
					"icon_path": items.icon_path,
					"slot_type": items.slot_type,
					"stats": items.stats,
					"resource_path": "res://item.gd"  # Default resource path
				}]
			else:
				print("Warning: Found null item in equipped_components[", slot, "] during save")
	var data = {
		"credits": credits,
		"scrap": scrap,
		"inventory": serialized_inventory,
		"equipment": serialized_equipment
	}
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found.")
		# Start with basic equipment and resources
		inventory.clear()
		equipped_components.clear()
		credits = 50  # Starting credits
		scrap = 25    # Starting scrap
		
		# Create starter items
		var starter_items = [
			{
				"name": "Pulse Laser Mk I",
				"description": "Entry-level laser cannon",
				"slot_type": "weapon",
				"icon_path": "res://items/pulse_laser.png",
				"resource_path": "res://components/laserWeapon.gd"
			},
			{
				"name": "Railgun Mk I",
				"description": "Basic kinetic weapon.",
				"slot_type": "weapon",
				"icon_path": "res://items/plasma-core.png",
				"resource_path": "res://item.gd"
			},
			{
				"name": "Basic Thruster",
				"description": "Reliable but slow thruster to get you around.",
				"slot_type": "engine",
				"icon_path": "res://items/basic_thruster.png",
				"resource_path": "res://item.gd"
			},
			{
				"name": "Afterburner",
				"description": "Short bursts of speed.",
				"slot_type": "engine",
				"icon_path": "res://items/plasma-core.png",
				"resource_path": "res://item.gd"
			}
		]
		
		# Convert starter_items to Item objects
		for item_data in starter_items:
			var resource_path = item_data.get("resource_path", "res://item.gd")
			
			# Create the correct resource type based on the slot_type
			var item_resource
			var slot_type = item_data.get("slot_type", "")
			var item_name = item_data.get("name", "")
			if slot_type == "weapon" and (resource_path == "res://components/laserWeapon.gd" or item_name.contains("Laser")):
				item_resource = load("res://components/laserWeapon.gd")
			elif slot_type == "weapon" and item_name.contains("Railgun"):
				item_resource = load("res://components/railgunWeapon.gd")
			else:
				item_resource = load(resource_path)
			
			var item = item_resource.new()
			item.name = item_data.get("name", "")
			item.description = item_data.get("description", "")
			item.icon_path = item_data.get("icon_path", "")
			item.slot_type = item_data.get("slot_type", "")
			item.stats = item_data.get("stats", {})
			item.icon = null
			if item.icon_path != "":
				item.icon = load(item.icon_path)
			item.resource_path = resource_path
			inventory.append(item)
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var result = JSON.parse_string(content)
	if result is Dictionary:
		credits = result.get("credits", 0)
		scrap = result.get("scrap", 0)
		inventory.clear()
		var starter_items = [
			{
				"name": "Pulse Laser Mk I",
				"description": "Entry-level laser cannon",
				"slot_type": "weapon",
				"icon_path": "res://items/pulse_laser.png",
				"resource_path": "res://components/laserWeapon.gd"
			},
			{
				"name": "Railgun Mk I",
				"description": "Basic kinetic weapon.",
				"slot_type": "weapon",
				"icon_path": "res://items/plasma-core.png",
				"resource_path": "res://item.gd"
			},
			{
				"name": "Basic Thruster",
				"description": "Reliable but slow thruster to get you around.",
				"slot_type": "engine",
				"icon_path": "res://items/basic_thruster.png",
				"resource_path": "res://item.gd"
			},
			{
				"name": "Afterburner",
				"description": "Short bursts of speed.",
				"slot_type": "engine",
				"icon_path": "res://items/plasma-core.png",
				"resource_path": "res://item.gd"
			}
		]
		var loaded_inventory = result.get("inventory", starter_items)
		for item_data in loaded_inventory:
			var resource_path = item_data.get("resource_path", "res://item.gd")
			if resource_path == "" or resource_path == "res://":
				resource_path = "res://item.gd"
			
			# Create the correct resource type based on the slot_type
			var item_resource
			var slot_type = item_data.get("slot_type", "")
			var item_name = item_data.get("name", "")
			if slot_type == "weapon" and (resource_path == "res://components/laserWeapon.gd" or item_name.contains("Laser")):
				item_resource = load("res://components/laserWeapon.gd")
			elif slot_type == "weapon" and item_name.contains("Railgun"):
				item_resource = load("res://components/railgunWeapon.gd")
			else:
				item_resource = load(resource_path)
			
			var item = item_resource.new()
			item.name = item_data.get("name", "")
			item.description = item_data.get("description", "")
			item.icon_path = item_data.get("icon_path", "")
			item.slot_type = item_data.get("slot_type", "")
			item.stats = item_data.get("stats", {})
			item.icon = null
			if item.icon_path != "":
				item.icon = load(item.icon_path)
			# Don't set resource_path to avoid cyclic inclusion
			# item.resource_path = resource_path
			inventory.append(item)
		equipped_components.clear()
		var loaded_equipment = result.get("equipment", starter_items)
		equipped_components.clear()
		for slot in loaded_equipment:
			var items_data = loaded_equipment[slot]
			var items_array = []
			for item_data in items_data:
				var resource_path = item_data.get("resource_path", "res://item.gd")
				if resource_path == "" or resource_path == "res://":
					resource_path = "res://item.gd"
				
				# Create the correct resource type based on the slot
				var item_resource
				if slot == "weapon" and (resource_path == "res://components/laserWeapon.gd" or item_data.get("name", "").contains("Laser")):
					item_resource = load("res://components/laserWeapon.gd")
				elif slot == "weapon" and item_data.get("name", "").contains("Railgun"):
					item_resource = load("res://components/railgunWeapon.gd")
				else:
					item_resource = load(resource_path)
				
				var equipped_item = item_resource.new()
				equipped_item.name = item_data.get("name", "")
				equipped_item.description = item_data.get("description", "")
				equipped_item.icon_path = item_data.get("icon_path", "")
				equipped_item.slot_type = item_data.get("slot_type", "")
				equipped_item.stats = item_data.get("stats", {})
				equipped_item.icon = null
				if equipped_item.icon_path != "":
					equipped_item.icon = load(equipped_item.icon_path)
				# Don't set resource_path to avoid cyclic inclusion
				# equipped_item.resource_path = resource_path
				items_array.append(equipped_item)
			equipped_components[slot] = items_array
	cleanup_null_items()

func cleanup_null_items():
	# Remove null items from inventory
	var cleaned_inventory = []
	for item in inventory:
		if item != null:
			cleaned_inventory.append(item)
		else:
			print("Removing null item from inventory")
	inventory = cleaned_inventory
	
	# Remove null items from equipped components
	for slot in equipped_components:
		var items = equipped_components[slot]
		if typeof(items) == TYPE_ARRAY:
			var cleaned_items = []
			for item in items:
				if item != null:
					cleaned_items.append(item)
				else:
					print("Removing null item from equipped_components[", slot, "]")
			equipped_components[slot] = cleaned_items
		else:
			# Backward compatibility: single item
			if items == null:
				print("Removing null item from equipped_components[", slot, "]")
				equipped_components.erase(slot)

func get_equipped_weapons() -> Array:
	return equipped_components["weapon"] if equipped_components.has("weapon") else []

func add_scrap(amount: int):
	scrap += amount
	save_game()
	print("Added", amount, "scrap. Total:", scrap)
