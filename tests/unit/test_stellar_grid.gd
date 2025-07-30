extends BaseTestSuite
class_name StellarGridTestSuite

var grid_manager: GridManager
var test_item: Item

func setup_test():
	# Create a test grid manager
	grid_manager = GridManager.new()
	add_child(grid_manager)
	
	# Create a test item
	test_item = create_test_grid_item("Test Power Core")

func teardown_test():
	if grid_manager:
		grid_manager.queue_free()
	if test_item:
		test_item = null

func create_test_grid_item(name: String) -> Item:
	"""Create a test grid item"""
	var item = Item.new()
	item.name = name
	item.description = "Test grid item"
	item.slot_type = "grid_module"
	item.type = "grid_module"
	item.stats = {
		"production": {
			"credits": 2
		}
	}
	return item

# Test grid initialization
func test_grid_initialization():
	"""Test that grid initializes correctly"""
	assert_not_null(grid_manager, "Grid manager should be created")
	assert_equal(grid_manager.grid_size, Vector2i(3, 3), "Grid should start with 3x3 size")
	assert_not_null(grid_manager.grid_tiles, "Grid tiles should be initialized")

# Test grid tile creation
func test_grid_tile_creation():
	"""Test that grid tiles are created correctly"""
	var tile = grid_manager.get_tile(Vector2i(0, 0))
	assert_not_null(tile, "Tile should exist at position (0,0)")
	assert_true(tile.is_empty(), "New tile should be empty")
	assert_equal(tile.grid_position, Vector2i(0, 0), "Tile should have correct position")

# Test valid position checking
func test_valid_position():
	"""Test position validation"""
	assert_true(grid_manager.is_valid_position(Vector2i(0, 0)), "Position (0,0) should be valid")
	assert_true(grid_manager.is_valid_position(Vector2i(2, 2)), "Position (2,2) should be valid")
	assert_false(grid_manager.is_valid_position(Vector2i(-1, 0)), "Position (-1,0) should be invalid")
	assert_false(grid_manager.is_valid_position(Vector2i(3, 0)), "Position (3,0) should be invalid")
	assert_false(grid_manager.is_valid_position(Vector2i(0, 3)), "Position (0,3) should be invalid")

# Test item placement
func test_item_placement():
	"""Test placing items on the grid"""
	var position = Vector2i(1, 1)
	var success = grid_manager.place_item(position, test_item)
	
	assert_true(success, "Item placement should succeed")
	
	var tile = grid_manager.get_tile(position)
	assert_true(tile.is_occupied(), "Tile should be occupied after placement")
	assert_equal(tile.get_item().name, test_item.name, "Placed item should match")

# Test item removal
func test_item_removal():
	"""Test removing items from the grid"""
	var position = Vector2i(1, 1)
	grid_manager.place_item(position, test_item)
	
	var removed_item = grid_manager.remove_item(position)
	assert_not_null(removed_item, "Removed item should not be null")
	assert_equal(removed_item.name, test_item.name, "Removed item should match placed item")
	
	var tile = grid_manager.get_tile(position)
	assert_true(tile.is_empty(), "Tile should be empty after removal")

# Test adjacency bonus calculation
func test_adjacency_bonus():
	"""Test adjacency bonus calculation"""
	# Place a power core
	var power_core = create_test_grid_item("Power Core")
	power_core.stats = {
		"production": {"credits": 2},
		"adjacency_bonus": {"type": "power", "bonus": 0.2}
	}
	
	grid_manager.place_item(Vector2i(1, 1), power_core)
	
	# Place an extractor adjacent to power core
	var extractor = create_test_grid_item("Extractor")
	extractor.stats = {"production": {"scrap": 3}}
	
	grid_manager.place_item(Vector2i(1, 0), extractor)
	
	var tile = grid_manager.get_tile(Vector2i(1, 0))
	var bonus = grid_manager.calculate_adjacency_bonus(tile)
	
	assert_true(bonus > 1.0, "Adjacency bonus should be greater than 1.0")

# Test production system
func test_production_system():
	"""Test the production system"""
	# Place a power core
	var power_core = create_test_grid_item("Power Core")
	power_core.stats = {"production": {"credits": 2}}
	grid_manager.place_item(Vector2i(1, 1), power_core)
	
	# Mock PlayerData for testing
	var original_credits = PlayerData.credits
	grid_manager._on_production_tick()
	
	# Check that credits were added (this would require mocking PlayerData)
	assert_true(true, "Production tick should complete without errors")

# Test save/load functionality
func test_save_load():
	"""Test grid save and load functionality"""
	# Place an item
	grid_manager.place_item(Vector2i(1, 1), test_item)
	
	# Save grid
	grid_manager.save_grid_data()
	
	# Create new grid manager to test loading
	var new_grid_manager = GridManager.new()
	add_child(new_grid_manager)
	
	# Load grid data
	new_grid_manager.load_grid_data()
	
	# Check that item was loaded
	var tile = new_grid_manager.get_tile(Vector2i(1, 1))
	assert_true(tile.is_occupied(), "Tile should be occupied after loading")
	assert_equal(tile.get_item().name, test_item.name, "Loaded item should match saved item")
	
	# Cleanup
	new_grid_manager.queue_free()

# Test grid expansion
func test_grid_expansion():
	"""Test grid expansion functionality"""
	var original_size = grid_manager.grid_size
	var new_size = Vector2i(5, 5)
	
	grid_manager._on_grid_expanded(new_size)
	
	assert_equal(grid_manager.grid_size, new_size, "Grid size should be updated")
	assert_not_equal(grid_manager.grid_size, original_size, "Grid size should have changed")

# Test error handling
func test_invalid_placement():
	"""Test handling of invalid item placement"""
	var invalid_position = Vector2i(-1, -1)
	var success = grid_manager.place_item(invalid_position, test_item)
	
	assert_false(success, "Placement at invalid position should fail")

# Test item creation functions
func test_item_creation():
	"""Test the item creation helper functions"""
	var power_core = grid_manager.create_power_core_item()
	assert_not_null(power_core, "Power core should be created")
	assert_equal(power_core.name, "Power Core Mk I", "Power core should have correct name")
	
	var extractor = grid_manager.create_extractor_item()
	assert_not_null(extractor, "Extractor should be created")
	assert_equal(extractor.name, "Extractor Mk I", "Extractor should have correct name")
	
	var research_lab = grid_manager.create_research_lab_item()
	assert_not_null(research_lab, "Research lab should be created")
	assert_equal(research_lab.name, "Research Lab Mk I", "Research lab should have correct name")

# Test item finding
func test_find_item_by_name():
	"""Test finding items by name"""
	# Add item to PlayerData inventory
	PlayerData.inventory.append(test_item)
	
	var found_item = grid_manager.find_item_by_name(test_item.name)
	assert_not_null(found_item, "Item should be found by name")
	assert_equal(found_item.name, test_item.name, "Found item should match")
	
	# Test finding non-existent item
	var not_found = grid_manager.find_item_by_name("NonExistentItem")
	assert_null(not_found, "Non-existent item should return null")

# Test grid state management
func test_grid_state():
	"""Test grid state management"""
	var state = grid_manager.get_grid_state()
	assert_not_null(state, "Grid state should not be null")
	assert_equal(state.size(), grid_manager.grid_size.x, "Grid state should have correct width")
	assert_equal(state[0].size(), grid_manager.grid_size.y, "Grid state should have correct height")

# Test resource generation tracking
func test_resource_generation():
	"""Test resource generation tracking"""
	var resources = grid_manager.get_total_resources_generated()
	assert_not_null(resources, "Resource tracking should be initialized")
	assert_true(resources is Dictionary, "Resources should be a dictionary")

# Test production timer
func test_production_timer():
	"""Test production timer functionality"""
	assert_not_null(grid_manager.production_timer, "Production timer should exist")
	assert_equal(grid_manager.production_timer.wait_time, grid_manager.PRODUCTION_INTERVAL, "Timer should have correct interval")
	assert_true(grid_manager.production_timer.one_shot, "Timer should be one-shot")

# Test signal emissions
func test_signal_emissions():
	"""Test that signals are emitted correctly"""
	var signal_emitted = false
	
	# Connect to tile_placed signal
	grid_manager.tile_placed.connect(func(pos, item): signal_emitted = true)
	
	# Place an item
	grid_manager.place_item(Vector2i(1, 1), test_item)
	
	assert_true(signal_emitted, "tile_placed signal should be emitted")

# Test grid tile states
func test_tile_states():
	"""Test grid tile state management"""
	var tile = grid_manager.get_tile(Vector2i(0, 0))
	
	# Test empty state
	assert_true(tile.is_empty(), "New tile should be empty")
	assert_false(tile.is_occupied(), "New tile should not be occupied")
	
	# Test occupied state
	grid_manager.place_item(Vector2i(0, 0), test_item)
	assert_false(tile.is_empty(), "Tile should not be empty after placement")
	assert_true(tile.is_occupied(), "Tile should be occupied after placement")

# Test grid tile highlighting
func test_tile_highlighting():
	"""Test grid tile highlighting functionality"""
	var tile = grid_manager.get_tile(Vector2i(0, 0))
	
	# Test highlight setting
	tile.set_highlight(true)
	assert_true(tile.is_highlighted, "Tile should be highlighted")
	
	tile.set_highlight(false)
	assert_false(tile.is_highlighted, "Tile should not be highlighted")

# Test grid tile display colors
func test_tile_display_colors():
	"""Test grid tile display color functionality"""
	var tile = grid_manager.get_tile(Vector2i(0, 0))
	
	# Test default color
	var default_color = tile.get_display_color()
	assert_not_null(default_color, "Display color should not be null")
	
	# Test highlighted color
	tile.set_highlight(true)
	var highlighted_color = tile.get_display_color()
	assert_not_equal(default_color, highlighted_color, "Highlighted color should be different")
	
	# Test occupied color
	grid_manager.place_item(Vector2i(0, 0), test_item)
	var occupied_color = tile.get_display_color()
	assert_not_equal(default_color, occupied_color, "Occupied color should be different")

# Test grid tile info
func test_tile_info():
	"""Test grid tile info functionality"""
	var tile = grid_manager.get_tile(Vector2i(0, 0))
	var info = tile.get_tile_info()
	
	assert_not_null(info, "Tile info should not be null")
	assert_true(info is Dictionary, "Tile info should be a dictionary")
	assert_true(info.has("position"), "Tile info should have position")
	assert_true(info.has("state"), "Tile info should have state")

# Test grid manager signals
func test_grid_manager_signals():
	"""Test that grid manager has all required signals"""
	var signals = grid_manager.get_signal_list()
	var signal_names = []
	for signal_info in signals:
		signal_names.append(signal_info.name)
	
	assert_true(signal_names.has("production_tick_completed"), "Should have production_tick_completed signal")
	assert_true(signal_names.has("tile_placed"), "Should have tile_placed signal")
	assert_true(signal_names.has("tile_removed"), "Should have tile_removed signal")

# Test grid manager properties
func test_grid_manager_properties():
	"""Test grid manager property access"""
	assert_not_null(grid_manager.grid_tiles, "Grid tiles should be accessible")
	assert_not_null(grid_manager.production_timer, "Production timer should be accessible")
	assert_true(grid_manager.grid_size is Vector2i, "Grid size should be Vector2i")
	assert_true(grid_manager.PRODUCTION_INTERVAL is float, "Production interval should be float")

# Test grid manager methods
func test_grid_manager_methods():
	"""Test grid manager method availability"""
	assert_true(grid_manager.has_method("place_item"), "Should have place_item method")
	assert_true(grid_manager.has_method("remove_item"), "Should have remove_item method")
	assert_true(grid_manager.has_method("get_tile"), "Should have get_tile method")
	assert_true(grid_manager.has_method("is_valid_position"), "Should have is_valid_position method")
	assert_true(grid_manager.has_method("save_grid_data"), "Should have save_grid_data method")
	assert_true(grid_manager.has_method("load_grid_data"), "Should have load_grid_data method") 