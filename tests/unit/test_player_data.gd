extends BaseTestSuite
class_name PlayerDataTestSuite

var original_save_path: String

func setup_test():
	# Store original save path and use a test path
	original_save_path = PlayerData.SAVE_FILE_PATH
	PlayerData.SAVE_FILE_PATH = "user://test_save.json"
	
	# Clear any existing test data
	PlayerData.credits = 0
	PlayerData.scrap = 0
	PlayerData.inventory.clear()
	PlayerData.equipped_components.clear()

func teardown_test():
	# Restore original save path
	PlayerData.SAVE_FILE_PATH = original_save_path
	
	# Clean up test files
	if FileAccess.file_exists("user://test_save.json"):
		DirAccess.remove_absolute("user://test_save.json")

# Test basic save/load functionality
func test_save_and_load_game():
	# Set up test data
	PlayerData.credits = 150
	PlayerData.scrap = 75
	PlayerData.inventory.append(create_test_item("Test Weapon", "weapon"))
	
	# Save the game
	PlayerData.save_game()
	
	# Verify save file exists
	assert_true(FileAccess.file_exists(PlayerData.SAVE_FILE_PATH), "Save file should exist")
	
	# Clear data and reload
	PlayerData.credits = 0
	PlayerData.scrap = 0
	PlayerData.inventory.clear()
	
	# Load the game
	PlayerData.load_game()
	
	# Verify data was restored
	assert_equal(150, PlayerData.credits, "Credits should be restored")
	assert_equal(75, PlayerData.scrap, "Scrap should be restored")
	assert_equal(1, PlayerData.inventory.size(), "Inventory should have one item")
	assert_equal("Test Weapon", PlayerData.inventory[0].name, "Inventory item should be restored")

# Test initial game state (no save file)
func test_initial_game_state():
	# Remove any existing save file
	if FileAccess.file_exists(PlayerData.SAVE_FILE_PATH):
		DirAccess.remove_absolute(PlayerData.SAVE_FILE_PATH)
	
	# Load game (should create initial state)
	PlayerData.load_game()
	
	# Verify initial state
	assert_equal(50, PlayerData.credits, "Should start with 50 credits")
	assert_equal(25, PlayerData.scrap, "Should start with 25 scrap")
	assert_true(PlayerData.inventory.size() > 0, "Should have starter items")
	
	# Check that starter items have correct slot types
	var has_weapon = false
	var has_engine = false
	for item in PlayerData.inventory:
		if item.slot_type == "weapon":
			has_weapon = true
		elif item.slot_type == "engine":
			has_engine = true
	
	assert_true(has_weapon, "Should have at least one weapon")
	assert_true(has_engine, "Should have at least one engine")

# Test inventory management
func test_add_and_remove_inventory_items():
	PlayerData.load_game()
	var initial_size = PlayerData.inventory.size()
	
	# Add a test item
	var test_item = create_test_item("New Test Item", "weapon")
	PlayerData.inventory.append(test_item)
	
	assert_equal(initial_size + 1, PlayerData.inventory.size(), "Inventory should have one more item")
	assert_equal("New Test Item", PlayerData.inventory[-1].name, "Last item should be the new test item")
	
	# Remove the item
	PlayerData.inventory.pop_back()
	assert_equal(initial_size, PlayerData.inventory.size(), "Inventory should be back to original size")

# Test equipment management
func test_equip_and_unequip_items():
	PlayerData.load_game()
	
	# Get a weapon from inventory
	var weapon = null
	for item in PlayerData.inventory:
		if item.slot_type == "weapon":
			weapon = item
			break
	
	assert_not_null(weapon, "Should have a weapon in inventory")
	
	# Equip the weapon
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var initial_equipped_count = equipped_weapons.size()
	
	# Add weapon to equipped components
	if not PlayerData.equipped_components.has("weapon"):
		PlayerData.equipped_components["weapon"] = []
	PlayerData.equipped_components["weapon"].append(weapon)
	
	# Verify weapon is equipped
	equipped_weapons = PlayerData.get_equipped_weapons()
	assert_equal(initial_equipped_count + 1, equipped_weapons.size(), "Should have one more equipped weapon")
	assert_equal(weapon.name, equipped_weapons[-1].name, "Equipped weapon should match")

# Test resource loading for different item types
func test_resource_loading_weapons():
	PlayerData.load_game()
	
	# Check that weapons loaded properly
	var weapon_count = 0
	for item in PlayerData.inventory:
		if item.slot_type == "weapon":
			weapon_count += 1
			assert_not_null(item, "Weapon item should not be null")
			assert_true(item.name != "", "Weapon should have a name")
			assert_true(item.description != "", "Weapon should have a description")
	
	assert_true(weapon_count > 0, "Should have at least one weapon")

func test_resource_loading_engines():
	PlayerData.load_game()
	
	# Check that engines loaded properly
	var engine_count = 0
	for item in PlayerData.inventory:
		if item.slot_type == "engine":
			engine_count += 1
			assert_not_null(item, "Engine item should not be null")
			assert_true(item.name != "", "Engine should have a name")
			assert_true(item.description != "", "Engine should have a description")
	
	assert_true(engine_count > 0, "Should have at least one engine")

# Test error handling for invalid resources
func test_error_handling_invalid_resources():
	# This test verifies that the system handles invalid resource paths gracefully
	# We can't easily test this without breaking the actual system, but we can
	# verify that the cleanup functions work properly
	
	PlayerData.load_game()
	var initial_size = PlayerData.inventory.size()
	
	# Call cleanup function
	PlayerData.cleanup_null_items()
	
	# Size should remain the same (no null items in normal operation)
	assert_equal(initial_size, PlayerData.inventory.size(), "Inventory size should remain the same after cleanup")

# Test scrap management
func test_add_scrap():
	PlayerData.load_game()
	var initial_scrap = PlayerData.scrap
	
	PlayerData.add_scrap(25)
	
	assert_equal(initial_scrap + 25, PlayerData.scrap, "Scrap should be increased by 25")
	
	# Verify save was called (we can't easily test this, but we can verify the value changed)
	assert_true(PlayerData.scrap > initial_scrap, "Scrap should have increased")

# Test save file corruption handling
func test_corrupted_save_file():
	# Create a corrupted save file
	var corrupted_data = "This is not valid JSON"
	var file = FileAccess.open(PlayerData.SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(corrupted_data)
	file.close()
	
	# Load should handle corruption gracefully and create initial state
	PlayerData.load_game()
	
	# Should have initial state
	assert_equal(50, PlayerData.credits, "Should fall back to initial credits")
	assert_equal(25, PlayerData.scrap, "Should fall back to initial scrap")
	assert_true(PlayerData.inventory.size() > 0, "Should have starter items")

# Test equipment serialization
func test_equipment_serialization():
	PlayerData.load_game()
	
	# Add some equipment
	var test_weapon = create_test_weapon("Serialization Test Weapon")
	var test_engine = create_test_engine("Serialization Test Engine")
	
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = [test_engine]
	
	# Save the game
	PlayerData.save_game()
	
	# Clear equipment and reload
	PlayerData.equipped_components.clear()
	PlayerData.load_game()
	
	# Verify equipment was restored
	assert_true(PlayerData.equipped_components.has("weapon"), "Should have weapon equipment")
	assert_true(PlayerData.equipped_components.has("engine"), "Should have engine equipment")
	assert_equal(1, PlayerData.equipped_components["weapon"].size(), "Should have one equipped weapon")
	assert_equal(1, PlayerData.equipped_components["engine"].size(), "Should have one equipped engine") 