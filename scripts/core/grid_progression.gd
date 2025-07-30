# GridProgression.gd
# Handles grid expansion, modifiers, and progression systems
extends Node
class_name GridProgression

signal grid_expanded(new_size: Vector2i)
signal modifier_applied(modifier: Dictionary)
signal event_triggered(event: Dictionary)

# Grid expansion configuration
const BASE_EXPANSION_COST := 100
const EXPANSION_COST_MULTIPLIER := 1.5
const MAX_GRID_SIZE := Vector2i(8, 8)

# Current grid state
var current_grid_size: Vector2i = Vector2i(3, 3)
var expansion_level: int = 0
var unlocked_tiles: Array[Vector2i] = []

# Modifiers and events
var active_modifiers: Array[Dictionary] = []
var daily_modifiers: Array[Dictionary] = []
var environmental_tiles: Dictionary = {}

# Progression tracking
var total_resources_generated: Dictionary = {}
var modules_placed: int = 0
var research_points_earned: int = 0

func _ready():
	initialize_starter_grid()
	load_progression_data()

func initialize_starter_grid():
	"""Initialize the 3x3 starter grid with pre-placed modules"""
	current_grid_size = Vector2i(3, 3)
	expansion_level = 0
	
	# Unlock all 3x3 tiles
	for x in range(3):
		for y in range(3):
			unlocked_tiles.append(Vector2i(x, y))

func load_progression_data():
	"""Load progression data from save file"""
	var save_path = "user://grid_progression_save.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.data
			current_grid_size = Vector2i(data.get("grid_size", Vector2i(3, 3)))
			expansion_level = data.get("expansion_level", 0)
			unlocked_tiles = []
			for tile_data in data.get("unlocked_tiles", []):
				unlocked_tiles.append(Vector2i(tile_data.x, tile_data.y))
			active_modifiers = data.get("active_modifiers", [])
			total_resources_generated = data.get("total_resources_generated", {})

func save_progression_data():
	"""Save progression data to file"""
	var save_data = {
		"grid_size": current_grid_size,
		"expansion_level": expansion_level,
		"unlocked_tiles": [],
		"active_modifiers": active_modifiers,
		"total_resources_generated": total_resources_generated
	}
	
	for tile in unlocked_tiles:
		save_data.unlocked_tiles.append({"x": tile.x, "y": tile.y})
	
	var file = FileAccess.open("user://grid_progression_save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func can_expand_grid() -> bool:
	"""Check if the grid can be expanded"""
	return current_grid_size.x < MAX_GRID_SIZE.x or current_grid_size.y < MAX_GRID_SIZE.y

func get_expansion_cost() -> int:
	"""Get the cost to expand the grid"""
	return int(BASE_EXPANSION_COST * pow(EXPANSION_COST_MULTIPLIER, expansion_level))

func expand_grid(direction: String) -> bool:
	"""Expand the grid in the specified direction"""
	if not can_expand_grid():
		return false
	
	var cost = get_expansion_cost()
	if PlayerData.credits < cost:
		return false
	
	# Deduct credits
	PlayerData.credits -= cost
	expansion_level += 1
	
	# Expand grid
	match direction:
		"right":
			if current_grid_size.x < MAX_GRID_SIZE.x:
				current_grid_size.x += 1
				# Unlock new tiles
				for y in range(current_grid_size.y):
					unlocked_tiles.append(Vector2i(current_grid_size.x - 1, y))
		"down":
			if current_grid_size.y < MAX_GRID_SIZE.y:
				current_grid_size.y += 1
				# Unlock new tiles
				for x in range(current_grid_size.x):
					unlocked_tiles.append(Vector2i(x, current_grid_size.y - 1))
	
	grid_expanded.emit(current_grid_size)
	save_progression_data()
	
	# Apply environmental tiles to new areas
	apply_environmental_tiles()
	
	return true

func apply_environmental_tiles():
	"""Apply environmental modifiers to new tiles"""
	var environmental_chances = {
		"mineral_rich": 0.15,
		"unstable": 0.10,
		"energy_field": 0.08,
		"research_boost": 0.05
	}
	
	for tile in unlocked_tiles:
		if not environmental_tiles.has(tile):
			for modifier in environmental_chances:
				if randf() < environmental_chances[modifier]:
					environmental_tiles[tile] = modifier
					break

func get_tile_modifier(tile_position: Vector2i) -> String:
	"""Get the environmental modifier for a specific tile"""
	return environmental_tiles.get(tile_position, "")

func is_tile_unlocked(tile_position: Vector2i) -> bool:
	"""Check if a tile is unlocked"""
	return tile_position in unlocked_tiles

func apply_daily_modifier():
	"""Apply a random daily modifier"""
	var daily_modifiers = [
		{
			"name": "Solar Flare Day",
			"description": "Power modules produce 2x output, but Research Labs are disabled",
			"duration": 86400,  # 24 hours in seconds
			"effects": {
				"power_multiplier": 2.0,
				"research_disabled": true
			}
		},
		{
			"name": "Efficiency Boost",
			"description": "All modules produce 1.5x output",
			"duration": 86400,
			"effects": {
				"global_multiplier": 1.5
			}
		},
		{
			"name": "Research Focus",
			"description": "Research Labs produce 3x blueprint fragments",
			"duration": 86400,
			"effects": {
				"research_multiplier": 3.0
			}
		},
		{
			"name": "Mineral Rush",
			"description": "Extractors produce 2x scrap",
			"duration": 86400,
			"effects": {
				"extraction_multiplier": 2.0
			}
		}
	]
	
	# Apply a random modifier
	var modifier = daily_modifiers[randi() % daily_modifiers.size()]
	active_modifiers.append(modifier)
	modifier_applied.emit(modifier)

func get_production_modifier(module_type: String) -> float:
	"""Get the production modifier for a specific module type"""
	var multiplier = 1.0
	
	for modifier in active_modifiers:
		var effects = modifier.get("effects", {})
		match module_type:
			"power":
				if effects.has("power_multiplier"):
					multiplier *= effects.power_multiplier
			"research":
				if effects.has("research_multiplier"):
					multiplier *= effects.research_multiplier
			"extractor":
				if effects.has("extraction_multiplier"):
					multiplier *= effects.extraction_multiplier
		
		# Global multiplier affects all modules
		if effects.has("global_multiplier"):
			multiplier *= effects.global_multiplier
	
	return multiplier

func trigger_random_event():
	"""Trigger a random grid event"""
	var events = [
		{
			"name": "Meteor Strike",
			"description": "A meteor has damaged some tiles! They need repair.",
			"effect": "damage_random_tiles",
			"duration": 3600  # 1 hour
		},
		{
			"name": "Energy Surge",
			"description": "Power modules are overloading! Adjacent modules get +50% bonus.",
			"effect": "power_surge",
			"duration": 1800  # 30 minutes
		},
		{
			"name": "Research Breakthrough",
			"description": "Research Labs have discovered something! +100% blueprint fragments.",
			"effect": "research_breakthrough",
			"duration": 7200  # 2 hours
		}
	]
	
	var event = events[randi() % events.size()]
	event_triggered.emit(event)
	
	# Apply event effects
	match event.effect:
		"damage_random_tiles":
			damage_random_tiles()
		"power_surge":
			apply_power_surge()
		"research_breakthrough":
			apply_research_breakthrough()

func damage_random_tiles():
	"""Damage random tiles (temporarily disable them)"""
	var damaged_tiles = []
	for i in range(min(3, unlocked_tiles.size())):
		var random_tile = unlocked_tiles[randi() % unlocked_tiles.size()]
		if random_tile not in damaged_tiles:
			damaged_tiles.append(random_tile)
	
	# Apply damage effect (tiles become temporarily unusable)
	for tile in damaged_tiles:
		environmental_tiles[tile] = "damaged"

func apply_power_surge():
	"""Apply power surge effect"""
	# This would be implemented to boost power-adjacent modules
	pass

func apply_research_breakthrough():
	"""Apply research breakthrough effect"""
	# This would be implemented to boost research output
	pass

func get_progression_stats() -> Dictionary:
	"""Get current progression statistics"""
	return {
		"grid_size": current_grid_size,
		"expansion_level": expansion_level,
		"unlocked_tiles": unlocked_tiles.size(),
		"total_tiles": current_grid_size.x * current_grid_size.y,
		"modules_placed": modules_placed,
		"research_points_earned": research_points_earned,
		"active_modifiers": active_modifiers.size()
	} 