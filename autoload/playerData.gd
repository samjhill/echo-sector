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
			# Determine the correct resource path based on the item type
			var resource_path = "res://scripts/core/item.gd"
			if item is LaserWeapon:
				resource_path = "res://components/laserWeapon.gd"
			elif item is RailgunWeapon:
				resource_path = "res://components/railgunWeapon.gd"
			
			serialized_inventory.append({
				"name": item.name,
				"description": item.description,
				"icon_path": item.icon_path,
				"slot_type": item.slot_type,
				"stats": item.stats,
				"resource_path": resource_path
			})
		else:
			Logger.warning("Found null item in inventory during save", "PlayerData")
	
	var serialized_equipment = {}
	for slot in equipped_components:
		var items = equipped_components[slot]
		if typeof(items) == TYPE_ARRAY:
			serialized_equipment[slot] = []
			for item in items:
				if item != null:
					# Determine the correct resource path based on the item type
					var resource_path = "res://scripts/core/item.gd"
					if item is LaserWeapon:
						resource_path = "res://components/laserWeapon.gd"
					elif item is RailgunWeapon:
						resource_path = "res://components/railgunWeapon.gd"
					
					serialized_equipment[slot].append({
						"name": item.name,
						"description": item.description,
						"icon_path": item.icon_path,
						"slot_type": item.slot_type,
						"stats": item.stats,
						"resource_path": resource_path
					})
				else:
					Logger.warning("Found null item in equipped_components[%s] during save" % slot, "PlayerData")
		else:
			# Backward compatibility: single item
			if items != null:
				# Determine the correct resource path based on the item type
				var resource_path = "res://scripts/core/item.gd"
				if items is LaserWeapon:
					resource_path = "res://components/laserWeapon.gd"
				elif items is RailgunWeapon:
					resource_path = "res://components/railgunWeapon.gd"
				
				serialized_equipment[slot] = [{
					"name": items.name,
					"description": items.description,
					"icon_path": items.icon_path,
					"slot_type": items.slot_type,
					"stats": items.stats,
					"resource_path": resource_path
				}]
			else:
				Logger.warning("Found null item in equipped_components[%s] during save" % slot, "PlayerData")
	
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
		Logger.info("No save file found, creating new game", "PlayerData")
		# Start with basic equipment and resources
		inventory.clear()
		equipped_components.clear()
		credits = 50
		scrap = 25
		
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
				"resource_path": "res://components/railgunWeapon.gd"
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
			var resource_path = item_data.get("resource_path", "res://scripts/core/item.gd")
			var item_resource = load(resource_path)
			
			if item_resource == null:
				Logger.warning("Failed to load resource: %s, falling back to Item" % resource_path, "PlayerData")
				item_resource = load("res://scripts/core/item.gd")
			
			var item = item_resource.new()
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
		
		# Also add starter items directly as fallback
		var starter_grid_items = [
			{
				"name": "Power Core Mk I",
				"description": "Basic power generation module. Provides energy to adjacent modules.",
				"slot_type": "grid_module",
				"icon_path": "res://assets/textures/plasma-core.png",
				"stats": {
					"production": {
						"credits": 2
					},
					"adjacency_bonus": {
						"type": "power",
						"bonus": 0.2
					}
				}
			},
			{
				"name": "Extractor Mk I",
				"description": "Processes raw materials into scrap metal. Benefits from power adjacency.",
				"slot_type": "grid_module",
				"icon_path": "res://assets/textures/uranium.png",
				"stats": {
					"production": {
						"scrap": 3
					}
				}
			},
			{
				"name": "Research Lab Mk I",
				"description": "Generates research points and blueprint fragments for technology development.",
				"slot_type": "grid_module",
				"icon_path": "res://assets/textures/portal.png",
				"stats": {
					"production": {
						"research_points": 1,
						"blueprint_fragments": 1
					}
				}
			}
		]
		
		# Add starter grid items to inventory
		for item_data in starter_grid_items:
			var item = load("res://scripts/core/item.gd").new()
			item.name = item_data.get("name", "")
			item.description = item_data.get("description", "")
			item.slot_type = item_data.get("slot_type", "")
			item.icon_path = item_data.get("icon_path", "")
			item.stats = item_data.get("stats", {})
			item.type = "grid_module"
			if item.icon_path != "":
				item.icon = load(item.icon_path)
			inventory.append(item)
			Logger.info("Added starter grid item: %s (type: %s, slot_type: %s)" % [item.name, item.type, item.slot_type], "PlayerData")
		
		Logger.info("Total inventory items after adding grid items: %d" % inventory.size(), "PlayerData")
		
		# Initialize tutorial completion tracking
		tutorial_completed = {
			"stellar_grid": false
		}
		
		# Initialize equipped components
		equipped_components["weapon"] = []
		equipped_components["engine"] = []
		
		save_game()
		Logger.info("Created new save file with starter items", "PlayerData")
	else:
		Logger.info("Loading existing save file", "PlayerData")
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
							Logger.warning("Failed to load laserWeapon.gd, falling back to Item", "PlayerData")
							item_resource = load("res://scripts/core/item.gd")
					elif slot == "weapon" and item_data.get("name", "").contains("Railgun"):
						item_resource = load("res://components/railgunWeapon.gd")
						if item_resource == null:
							Logger.warning("Failed to load railgunWeapon.gd, falling back to Item", "PlayerData")
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
							Logger.warning("Failed to load engine component, falling back to Item", "PlayerData")
							item_resource = load("res://scripts/core/item.gd")
					else:
						item_resource = load(resource_path)
					
					# Check if resource loaded successfully
					if item_resource == null:
						Logger.error("Failed to load resource: %s" % resource_path, "PlayerData")
						Logger.debug("Item data: %s" % item_data, "PlayerData")
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
	"""Remove null items from inventory and equipped components"""
	var cleaned_inventory = []
	for item in inventory:
		if item != null:
			cleaned_inventory.append(item)
		else:
			Logger.warning("Removing null item from inventory", "PlayerData")
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
					Logger.warning("Removing null item from equipped_components[%s]" % slot, "PlayerData")
			equipped_components[slot] = cleaned_items
		else:
			# Backward compatibility: single item
			if items == null:
				Logger.warning("Removing null item from equipped_components[%s]" % slot, "PlayerData")
				equipped_components.erase(slot)

func get_equipped_weapons() -> Array:
	return equipped_components["weapon"] if equipped_components.has("weapon") else []

func get_equipped_engines() -> Array:
	return equipped_components["engine"] if equipped_components.has("engine") else []

func add_scrap(amount: int):
	"""Add scrap to player's total"""
	scrap += amount
	scrap_changed.emit(scrap)
	save_game()
	Logger.info("Added %d scrap. Total: %d" % [amount, scrap], "PlayerData")

func add_credits(amount: int):
	"""Add credits to player's total"""
	credits += amount
	credits_changed.emit(credits)
	save_game()
	Logger.info("Added %d credits. Total: %d" % [amount, credits], "PlayerData")

func add_item_to_inventory(item: Item):
	"""Add an item to the player's inventory"""
	if item != null:
		inventory.append(item)
		inventory_changed.emit()
		save_game()
		Logger.info("Added %s to inventory" % item.name, "PlayerData")
	else:
		Logger.error("Attempted to add null item to inventory", "PlayerData")

func remove_item_from_inventory(item: Item):
	"""Remove an item from the player's inventory"""
	if item != null:
		var index = inventory.find(item)
		if index != -1:
			inventory.remove_at(index)
			inventory_changed.emit()
			save_game()
			Logger.info("Removed %s from inventory" % item.name, "PlayerData")
		else:
			Logger.warning("Item not found in inventory: %s" % item.name, "PlayerData")
	else:
		Logger.error("Attempted to remove null item from inventory", "PlayerData")

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
