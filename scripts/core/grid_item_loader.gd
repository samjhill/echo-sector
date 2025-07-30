# GridItemLoader.gd
# Utility script for loading grid items from JSON configuration
extends RefCounted
class_name GridItemLoader

const GRID_ITEM_DATA_PATH = "res://data/grid_item_data.json"

static func load_grid_items() -> Dictionary:
	"""Load all grid items from the JSON configuration file"""
	var items = {}
	
	if not FileAccess.file_exists(GRID_ITEM_DATA_PATH):
		print("Grid item data file not found: ", GRID_ITEM_DATA_PATH)
		return items
	
	var file = FileAccess.open(GRID_ITEM_DATA_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Failed to parse grid item data JSON")
		return items
	
	var data = json.data
	var grid_items = data.get("grid_items", {})
	print("Found %d grid items in JSON" % grid_items.size())
	print("Grid item keys: ", grid_items.keys())
	
	for item_id in grid_items:
		var item_data = grid_items[item_id]
		var item = create_item_from_data(item_data)
		if item != null:
			items[item_id] = item
			print("Created item: %s (%s)" % [item.name, item_id])
		else:
			print("Failed to create item for ID: %s" % item_id)
	
	print("Loaded ", items.size(), " grid items")
	return items

static func create_item_from_data(item_data: Dictionary) -> Item:
	"""Create an Item instance from JSON data"""
	var item = load("res://scripts/core/item.gd").new()
	
	item.name = item_data.get("name", "")
	item.description = item_data.get("description", "")
	item.type = item_data.get("type", "grid_module")
	item.slot_type = item_data.get("slot_type", "grid_module")
	item.icon_path = item_data.get("icon_path", "")
	item.is_equippable = item_data.get("is_equippable", false)
	item.is_stackable = item_data.get("is_stackable", false)
	item.max_stack = item_data.get("max_stack", 1)
	item.stats = item_data.get("stats", {})
	item.effects = item_data.get("effects", [])
	
	# Load icon if path is provided
	if item.icon_path != "":
		item.icon = load(item.icon_path)
	
	return item

static func get_grid_item_by_name(item_name: String) -> Item:
	"""Get a specific grid item by name"""
	var all_items = load_grid_items()
	
	for item_id in all_items:
		var item = all_items[item_id]
		if item.name == item_name:
			return item
	
	return null

static func add_starter_grid_items_to_inventory():
	"""Add starter grid items to the player's inventory"""
	var starter_items = [
		"power_core_mk1",
		"extractor_mk1",
		"research_lab_mk1"
	]
	
	var all_items = load_grid_items()
	print("Loaded %d total grid items" % all_items.size())
	print("Available item IDs: ", all_items.keys())
	
	for item_id in starter_items:
		if item_id in all_items:
			var item = all_items[item_id]
			PlayerData.add_item_to_inventory(item)
			print("Added starter grid item: ", item.name)
		else:
			print("Starter grid item not found: ", item_id) 