# GridManager.gd
# Manages the Stellar Grid system - a tile-based strategic subsystem
extends Node
class_name GridManager

# Grid properties
var grid_size: Vector2i = Vector2i(3, 3)
var grid_tiles: Array[Array] = []
var production_timer: Timer
var last_production_time: int = 0

# Production tracking
var total_resources_generated: Dictionary = {}

# Progression system
var progression_system: GridProgression = null

# Buff visual manager
var buff_visual_manager: BuffVisualManager = null

# Signals
signal tile_placed(grid_position: Vector2i, item: Item)
signal tile_removed(grid_position: Vector2i, item: Item)
signal production_tick_completed(resources_generated: Dictionary)
signal grid_expanded(new_size: Vector2i)
signal modifier_applied(modifier: Dictionary)
signal event_triggered(event: Dictionary)

func _ready():
	Logger.info("Initializing GridManager", "GridManager")
	initialize_grid()
	setup_production_timer()
	load_grid_data()

func initialize_grid():
	"""Initialize the grid with empty tiles"""
	grid_tiles.clear()
	
	for x in range(grid_size.x):
		var column: Array[GridTile] = []
		for y in range(grid_size.y):
			var tile = GridTile.new()
			tile.grid_position = Vector2i(x, y)
			column.append(tile)
		grid_tiles.append(column)
	
	Logger.info("Initialized %dx%d grid" % [grid_size.x, grid_size.y], "GridManager")

func setup_production_timer():
	"""Setup the production timer for resource generation"""
	production_timer = Timer.new()
	production_timer.wait_time = 5.0  # 5 seconds between production ticks
	production_timer.timeout.connect(_on_production_tick)
	add_child(production_timer)
	production_timer.start()
	Logger.info("Production timer started (5s intervals)", "GridManager")

func setup_buff_visual_manager(visual_manager: BuffVisualManager):
	"""Setup the buff visual manager"""
	buff_visual_manager = visual_manager
	if buff_visual_manager:
		buff_visual_manager.setup(self, null)  # grid_container will be set by UI
		Logger.info("Buff visual manager connected", "GridManager")
		
		# Update buff visuals after setup to show existing interactions
		buff_visual_manager.update_all_buff_visuals()
		Logger.info("Updated buff visuals after buff visual manager setup", "GridManager")

func load_grid_data():
	"""Load grid data from save file"""
	if not FileAccess.file_exists("user://stellar_grid_save.json"):
		Logger.info("No grid save file found, starting with empty grid", "GridManager")
		return
	
	var file = FileAccess.open("user://stellar_grid_save.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var data = json.data
		var tiles_to_load = []
		
		# Collect tiles to load first
		if data.has("tiles"):
			for tile_data in data.tiles:
				var position_data = tile_data.get("position", {})
				var position: Vector2i
				
				if position_data is Dictionary:
					position = Vector2i(position_data.x, position_data.y)
				elif position_data is Array and position_data.size() >= 2:
					position = Vector2i(position_data[0], position_data[1])
				else:
					Logger.warning("Invalid position format in save data: %s" % position_data, "GridManager")
					continue
				
				tiles_to_load.append({
					"position": position,
					"item_name": tile_data.get("item_name", "")
				})
		
		# Update grid size if needed
		if data.has("grid_size"):
			var grid_size_data = data.grid_size
			if grid_size_data is Dictionary:
				grid_size = Vector2i(grid_size_data.x, grid_size_data.y)
			elif grid_size_data is Array and grid_size_data.size() >= 2:
				grid_size = Vector2i(grid_size_data[0], grid_size_data[1])
			else:
				Logger.warning("Invalid grid_size format in save data", "GridManager")
				grid_size = Vector2i(3, 3)  # Default fallback
		
		# Reinitialize grid with new size
		initialize_grid()
		
		# Now place the items on the newly initialized grid
		for tile_data in tiles_to_load:
			var item = find_item_by_name(tile_data.item_name)
			if item != null:
				var position = tile_data.position
				# Check if position is valid for the new grid size
				if is_valid_position(position):
					var tile = grid_tiles[position.x][position.y]
					tile.place_item(item)
					tile_placed.emit(position, item)
					Logger.info("Loaded item %s at position %s" % [tile_data.item_name, position], "GridManager")
				else:
					Logger.warning("Position %s is invalid for grid size %s" % [position, grid_size], "GridManager")
			else:
				Logger.warning("Could not find item %s for loading" % tile_data.item_name, "GridManager")
		
		Logger.info("Grid data loaded from save file", "GridManager")
		
		# Update buff visuals after loading grid data
		if buff_visual_manager:
			buff_visual_manager.update_all_buff_visuals()
			Logger.info("Updated buff visuals after loading grid data", "GridManager")
	else:
		Logger.error("Error parsing grid save data", "GridManager")

func save_grid_data():
	"""Save current grid state to file"""
	var save_data = {
		"grid_size": grid_size,
		"tiles": []
	}
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var tile = grid_tiles[x][y]
			if tile.tile_state == GridTile.TileState.OCCUPIED:
				save_data.tiles.append({
					"position": {"x": x, "y": y},
					"item_name": tile.placed_item.name,
					"item_type": tile.placed_item.type
				})
	
	var file = FileAccess.open("user://stellar_grid_save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func place_item(grid_position: Vector2i, item: Item) -> bool:
	"""Place an item on the grid at the specified position"""
	if not is_valid_position(grid_position):
		Logger.warning("Invalid grid position: %s" % grid_position, "GridManager")
		return false
	
	var tile = grid_tiles[grid_position.x][grid_position.y]
	if tile.tile_state != GridTile.TileState.EMPTY:
		Logger.warning("Tile already occupied at: %s" % grid_position, "GridManager")
		return false
	
	# Place the item
	tile.place_item(item)
	tile_placed.emit(grid_position, item)
	
	# Update buff visuals
	_update_buff_visuals_for_tile(tile)
	
	# Save grid state
	save_grid_data()
	
	Logger.info("Placed %s at grid position %s" % [item.name, grid_position], "GridManager")
	return true

func remove_item(grid_position: Vector2i) -> Item:
	"""Remove an item from the grid and return it to inventory"""
	if not is_valid_position(grid_position):
		return null
	
	var tile = grid_tiles[grid_position.x][grid_position.y]
	if tile.tile_state != GridTile.TileState.OCCUPIED:
		return null
	
	var item = tile.remove_item()
	if item:
		PlayerData.add_item_to_inventory(item)
		tile_removed.emit(grid_position, item)
		
		# Update buff visuals after removal
		_update_buff_visuals_after_removal(grid_position)
		
		save_grid_data()
	
	return item

func _update_buff_visuals_for_tile(tile: GridTile):
	"""Update buff visuals when a tile is placed"""
	if buff_visual_manager:
		buff_visual_manager.update_all_buff_visuals()

func _update_buff_visuals_after_removal(removed_position: Vector2i):
	"""Update buff visuals after a tile is removed"""
	if buff_visual_manager:
		# Clear buff states for adjacent tiles
		var adjacent_tiles = get_adjacent_tiles(removed_position)
		for adjacent_tile in adjacent_tiles:
			adjacent_tile.clear_buff_visuals()
		
		# Update all buff visuals
		buff_visual_manager.update_all_buff_visuals()

func is_valid_position(position: Vector2i) -> bool:
	"""Check if a grid position is valid"""
	return position.x >= 0 and position.x < grid_size.x and \
		   position.y >= 0 and position.y < grid_size.y

func get_tile(position: Vector2i) -> GridTile:
	"""Get a tile at the specified position"""
	if is_valid_position(position):
		return grid_tiles[position.x][position.y]
	return null

func get_adjacent_tiles(position: Vector2i) -> Array[GridTile]:
	"""Get all adjacent tiles (cardinal directions only)"""
	var adjacent: Array[GridTile] = []
	var directions = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
	
	for direction in directions:
		var adjacent_pos = position + direction
		if is_valid_position(adjacent_pos):
			adjacent.append(grid_tiles[adjacent_pos.x][adjacent_pos.y])
	
	return adjacent

func calculate_adjacency_bonus(tile: GridTile) -> float:
	"""Calculate adjacency bonus for a tile based on neighboring items"""
	if tile.tile_state != GridTile.TileState.OCCUPIED:
		return 1.0
	
	var bonus_multiplier = 1.0
	var adjacent_tiles = get_adjacent_tiles(tile.grid_position)
	
	for adjacent_tile in adjacent_tiles:
		if adjacent_tile.tile_state == GridTile.TileState.OCCUPIED:
			var adjacent_item = adjacent_tile.placed_item
			# Power Core provides +20% bonus to adjacent tiles
			if adjacent_item.name.contains("Power Core"):
				bonus_multiplier += 0.2
			# Research Lab provides +15% bonus to adjacent tiles
			elif adjacent_item.name.contains("Research Lab"):
				bonus_multiplier += 0.15
	
	return bonus_multiplier

func _on_production_tick():
	"""Handle production tick - generate resources from all active modules"""
	var resources_generated = {
		"credits": 0,
		"scrap": 0,
		"research_points": 0,
		"discovery_points": 0
	}
	
	# Process each occupied tile
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var tile = grid_tiles[x][y]
			if tile.tile_state == GridTile.TileState.OCCUPIED:
				var item = tile.placed_item
				var adjacency_bonus = calculate_adjacency_bonus(tile)
				
				# Generate resources based on item type
				var base_production = item.stats.get("production", {})
				for resource_type in base_production:
					var base_amount = base_production[resource_type]
					var bonus_amount = base_amount * (adjacency_bonus - 1.0)
					var total_amount = base_amount + bonus_amount
					
					if resource_type in resources_generated:
						resources_generated[resource_type] += total_amount
					else:
						resources_generated[resource_type] = total_amount
	
	# Add generated resources to player data using signal-emitting functions
	if resources_generated.credits > 0:
		PlayerData.add_credits(resources_generated.credits)
	if resources_generated.scrap > 0:
		PlayerData.add_scrap(resources_generated.scrap)
	
	# Store research and discovery points for future use
	if resources_generated.research_points > 0:
		total_resources_generated["research_points"] = total_resources_generated.get("research_points", 0) + resources_generated.research_points
	if resources_generated.discovery_points > 0:
		total_resources_generated["discovery_points"] = total_resources_generated.get("discovery_points", 0) + resources_generated.discovery_points
	
	last_production_time = Time.get_unix_time_from_system()
	production_tick_completed.emit(resources_generated)
	
	Logger.info("Production tick completed. Generated: %s" % resources_generated, "GridManager")

func get_total_resources_generated() -> Dictionary:
	"""Get the total resources generated since start"""
	return total_resources_generated

func get_grid_state() -> Array[Array]:
	"""Get the current state of the grid for UI display"""
	return grid_tiles

func _on_grid_expanded(new_size: Vector2i):
	"""Handle grid expansion from progression system"""
	grid_size = new_size
	Logger.info("Grid expanded to: %s" % new_size, "GridManager")

func _on_modifier_applied(modifier: Dictionary):
	"""Handle modifier application"""
	Logger.info("Modifier applied: %s" % modifier.name, "GridManager")

func _on_event_triggered(event: Dictionary):
	"""Handle random event"""
	Logger.info("Event triggered: %s" % event.name, "GridManager")

func find_item_by_name(item_name: String) -> Item:
	"""Find an item by name in the player's inventory or create it if it's a grid module"""
	# First, try to find in player inventory
	for item in PlayerData.inventory:
		if item != null and item.name == item_name:
			return item
	
	# If not found in inventory, try to create it based on the name
	# This handles cases where items were on the grid but not in inventory
	if item_name.contains("Power Core"):
		return create_power_core_item()
	elif item_name.contains("Extractor"):
		return create_extractor_item()
	elif item_name.contains("Research Lab"):
		return create_research_lab_item()
	
	Logger.warning("Could not find or create item: %s" % item_name, "GridManager")
	return null

func create_power_core_item() -> Item:
	"""Create a Power Core item"""
	var item = load("res://scripts/core/item.gd").new()
	item.name = "Power Core Mk I"
	item.description = "Basic power generation module. Provides energy to adjacent modules."
	item.slot_type = "grid_module"
	item.icon_path = "res://assets/textures/plasma-core.png"
	item.stats = {
		"production": {
			"credits": 2
		},
		"adjacency_bonus": {
			"type": "power",
			"bonus": 0.2
		}
	}
	item.type = "grid_module"
	if item.icon_path != "":
		item.icon = load(item.icon_path)
	return item

func create_extractor_item() -> Item:
	"""Create an Extractor item"""
	var item = load("res://scripts/core/item.gd").new()
	item.name = "Extractor Mk I"
	item.description = "Processes raw materials into scrap metal. Benefits from power adjacency."
	item.slot_type = "grid_module"
	item.icon_path = "res://assets/textures/uranium.png"
	item.stats = {
		"production": {
			"scrap": 3
		}
	}
	item.type = "grid_module"
	if item.icon_path != "":
		item.icon = load(item.icon_path)
	return item

func create_research_lab_item() -> Item:
	"""Create a Research Lab item"""
	var item = load("res://scripts/core/item.gd").new()
	item.name = "Research Lab Mk I"
	item.description = "Generates research points and blueprint fragments for technology development."
	item.slot_type = "grid_module"
	item.icon_path = "res://assets/textures/portal.png"
	item.stats = {
		"production": {
			"research_points": 1,
			"blueprint_fragments": 1
		}
	}
	item.type = "grid_module"
	if item.icon_path != "":
		item.icon = load(item.icon_path)
	return item 
