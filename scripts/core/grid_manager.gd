# GridManager.gd
# Manages the Stellar Grid system - a 5x5 tile-based strategic subsystem
extends Node
class_name GridManager

signal production_tick_completed(resources_generated: Dictionary)
signal tile_placed(grid_position: Vector2i, item: Item)
signal tile_removed(grid_position: Vector2i)

# Grid configuration
var grid_size: Vector2i = Vector2i(3, 3)  # Start with 3x3
const PRODUCTION_INTERVAL := 5.0  # seconds between production ticks

# Grid data structure
var grid_tiles: Array[Array] = []  # 2D array of GridTile nodes
var production_timer: Timer
var grid_container: GridContainer
var progression_system: GridProgression

# Production tracking
var last_production_time: float = 0.0
var total_resources_generated: Dictionary = {}

func _ready():
	setup_progression_system()
	initialize_grid()
	setup_production_timer()
	load_grid_data()

func setup_progression_system():
	"""Setup the progression system"""
	progression_system = GridProgression.new()
	progression_system.grid_expanded.connect(_on_grid_expanded)
	progression_system.modifier_applied.connect(_on_modifier_applied)
	progression_system.event_triggered.connect(_on_event_triggered)
	add_child(progression_system)
	
	# Update grid size from progression
	grid_size = progression_system.current_grid_size

func initialize_grid():
	"""Initialize the grid with empty GridTile nodes"""
	grid_tiles.resize(grid_size.x)
	for x in range(grid_size.x):
		grid_tiles[x] = []
		grid_tiles[x].resize(grid_size.y)
		for y in range(grid_size.y):
			var tile = GridTile.new()
			tile.grid_position = Vector2i(x, y)
			tile.tile_state = GridTile.TileState.EMPTY
			grid_tiles[x][y] = tile

func setup_production_timer():
	"""Setup the production timer for periodic resource generation"""
	production_timer = Timer.new()
	production_timer.wait_time = PRODUCTION_INTERVAL
	production_timer.timeout.connect(_on_production_tick)
	add_child(production_timer)
	production_timer.start()

func load_grid_data():
	"""Load grid data from save file if it exists"""
	var save_path = "user://stellar_grid_save.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.data
			# TODO: Implement grid loading from save data
			print("Grid data loaded from save file")

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
		print("Invalid grid position: ", grid_position)
		return false
	
	var tile = grid_tiles[grid_position.x][grid_position.y]
	if tile.tile_state != GridTile.TileState.EMPTY:
		print("Tile already occupied at: ", grid_position)
		return false
	
	# Place the item
	tile.place_item(item)
	tile_placed.emit(grid_position, item)
	
	# Remove item from inventory
	PlayerData.remove_item_from_inventory(item)
	
	# Save grid state
	save_grid_data()
	
	print("Placed ", item.name, " at grid position: ", grid_position)
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
		save_grid_data()
	
	return item

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
	
	# Add generated resources to player data
	if resources_generated.credits > 0:
		PlayerData.credits += resources_generated.credits
	if resources_generated.scrap > 0:
		PlayerData.scrap += resources_generated.scrap
	
	# Store research and discovery points for future use
	if resources_generated.research_points > 0:
		total_resources_generated["research_points"] = total_resources_generated.get("research_points", 0) + resources_generated.research_points
	if resources_generated.discovery_points > 0:
		total_resources_generated["discovery_points"] = total_resources_generated.get("discovery_points", 0) + resources_generated.discovery_points
	
	last_production_time = Time.get_unix_time_from_system()
	production_tick_completed.emit(resources_generated)
	
	print("Production tick completed. Generated: ", resources_generated)

func get_total_resources_generated() -> Dictionary:
	"""Get the total resources generated since start"""
	return total_resources_generated

func get_grid_state() -> Array[Array]:
	"""Get the current state of the grid for UI display"""
	return grid_tiles

func _on_grid_expanded(new_size: Vector2i):
	"""Handle grid expansion from progression system"""
	grid_size = new_size
	# TODO: Update UI grid display
	print("Grid expanded to: ", new_size)

func _on_modifier_applied(modifier: Dictionary):
	"""Handle modifier application"""
	print("Modifier applied: ", modifier.name)

func _on_event_triggered(event: Dictionary):
	"""Handle random event"""
	print("Event triggered: ", event.name) 
