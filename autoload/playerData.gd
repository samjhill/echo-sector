extends Node

var credits: int = 0
var scrap: int = 0
var inventory: Array = []
var equipped_components: Dictionary = {}
var tutorial_completed: Dictionary = {}

const SAVE_FILE_PATH := "user://save_data.json"

signal inventory_changed
signal credits_changed(new_amount: int)
signal scrap_changed(new_amount: int)

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
				"resource_path": "res://scripts/core/item.gd"  # Default resource path
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
						"resource_path": "res://scripts/core/item.gd"  # Default resource path
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
					"resource_path": "res://scripts/core/item.gd"  # Default resource path
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
				"resource_path": "res://scripts/core/item.gd"
			},
			{
				"name": "Basic Thruster",
				"description": "Reliable but slow thruster to get you around.",
				"slot_type": "engine",
				"icon_path": "res://items/basic_thruster.png",
				"resource_path": "res://scripts/core/item.gd"
			}
		]
		
		# Add starter items to inventory
		for item_data in starter_items:
			var item = load("res://scripts/core/item.gd").new()
			item.name = item_data.get("name", "")
			item.description = item_data.get("description", "")
			item.slot_type = item_data.get("slot_type", "")
			item.icon_path = item_data.get("icon_path", "")
			item.stats = item_data.get("stats", {})
			item.type = "grid_module" if item_data.get("slot_type") == "grid_module" else "weapon"
			if item.icon_path != "":
				item.icon = load(item.icon_path)
			inventory.append(item)
		
		# Add starter grid items using GridItemLoader
		GridItemLoader.add_starter_grid_items_to_inventory()
		
		# Initialize tutorial completion tracking
		tutorial_completed = {
			"stellar_grid": false
		}
		
		# Initialize equipped components
		equipped_components["weapon"] = []
		equipped_components["engine"] = []
		
		save_game()
		print("Created new save file with starter items.")
	else:
		print("Loading existing save file...")
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.data
			credits = data.get("credits", 0)
			scrap = data.get("scrap", 0)
			
			# Load inventory
			inventory.clear()
			var serialized_inventory = data.get("inventory", [])
			for item_data in serialized_inventory:
				var item = load("res://scripts/core/item.gd").new()
				item.name = item_data.get("name", "")
				item.description = item_data.get("description", "")
				item.slot_type = item_data.get("slot_type", "")
				item.icon_path = item_data.get("icon_path", "")
				item.stats = item_data.get("stats", {})
				item.type = "grid_module" if item_data.get("slot_type") == "grid_module" else "weapon"
				if item.icon_path != "":
					item.icon = load(item.icon_path)
				inventory.append(item)
			
			# Load equipped components
			equipped_components.clear()
			var serialized_equipment = data.get("equipment", {})
			for slot in serialized_equipment:
				var items_array = []
				var slot_items = serialized_equipment[slot]
				for item_data in slot_items:
					var resource_path = item_data.get("resource_path", "res://scripts/core/item.gd")
					if resource_path == "" or resource_path == "res://":
						resource_path = "res://scripts/core/item.gd"
					
					# Create the correct resource type based on the slot
					var item_resource
					if slot == "weapon" and (resource_path == "res://components/laserWeapon.gd" or item_data.get("name", "").contains("Laser")):
						item_resource = load("res://components/laserWeapon.gd")
						if item_resource == null:
							print("WARNING: Failed to load laserWeapon.gd, falling back to Item")
							item_resource = load("res://scripts/core/item.gd")
					elif slot == "weapon" and item_data.get("name", "").contains("Railgun"):
						item_resource = load("res://components/railgunWeapon.gd")
						if item_resource == null:
							print("WARNING: Failed to load railgunWeapon.gd, falling back to Item")
							item_resource = load("res://scripts/core/item.gd")
					elif slot == "engine":
						# For engine components, try to load the specific engine resource
						var item_name = item_data.get("name", "")
						if item_name.contains("Basic Thruster"):
							item_resource = load("res://components/basic_engine.tres")
						elif item_name.contains("Afterburner"):
							# Load the afterburner engine resource
							item_resource = load("res://components/afterburner_engine.tres")
						else:
							item_resource = load(resource_path)
						if item_resource == null:
							print("WARNING: Failed to load engine component, falling back to Item")
							item_resource = load("res://scripts/core/item.gd")
					else:
						item_resource = load(resource_path)
					
					# Check if resource loaded successfully
					if item_resource == null:
						print("ERROR: Failed to load resource: ", resource_path)
						print("Item data: ", item_data)
						continue
					
					var equipped_item
					if item_resource is Resource and not item_resource is Script:
						# For .tres files, we get an instance directly
						equipped_item = item_resource
						# Update the item with the data from the loaded equipment
						equipped_item.name = item_data.get("name", "")
						equipped_item.description = item_data.get("description", "")
						equipped_item.slot_type = item_data.get("slot_type", "")
						if item_data.get("icon_path", "") != "":
							equipped_item.icon = load(item_data.get("icon_path", ""))
					else:
						# For .gd files, we need to instantiate
						equipped_item = item_resource.new()
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

func get_equipped_engines() -> Array:
	return equipped_components["engine"] if equipped_components.has("engine") else []

func add_scrap(amount: int):
	scrap += amount
	scrap_changed.emit(scrap)
	save_game()
	print("Added", amount, "scrap. Total:", scrap)

func add_credits(amount: int):
	credits += amount
	credits_changed.emit(credits)
	save_game()
	print("Added", amount, "credits. Total:", credits)

func add_item_to_inventory(item: Item):
	"""Add an item to the player's inventory"""
	if item != null:
		inventory.append(item)
		inventory_changed.emit()
		save_game()
		print("Added", item.name, "to inventory")

func remove_item_from_inventory(item: Item):
	"""Remove an item from the player's inventory"""
	if item != null:
		var index = inventory.find(item)
		if index != -1:
			inventory.remove_at(index)
			inventory_changed.emit()
			save_game()
			print("Removed", item.name, "from inventory")
		else:
			print("Item not found in inventory:", item.name)

func get_inventory_items() -> Array[Item]:
	"""Get all items in the inventory"""
	return inventory

func get_grid_compatible_items() -> Array[Item]:
	"""Get items from inventory that can be placed on the grid"""
	var compatible_items: Array[Item] = []
	
	for item in inventory:
		if item != null and item.type == "grid_module":
			compatible_items.append(item)
	
	return compatible_items

func set_tutorial_completed(tutorial_name: String, completed: bool):
	"""Set tutorial completion status"""
	tutorial_completed[tutorial_name] = completed
	save_game()

func get_tutorial_completed(tutorial_name: String, default_value: bool = false) -> bool:
	"""Get tutorial completion status"""
	return tutorial_completed.get(tutorial_name, default_value)
