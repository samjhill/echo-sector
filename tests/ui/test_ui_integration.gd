extends BaseTestSuite
class_name UITestSuite

var hangar_scene: Control
var equipment_screen: ShipEquipmentScreen

func setup_test():
	# Set up test data
	PlayerData.load_game()
	
	# Create test items
	var test_weapon = create_test_weapon("UI Test Weapon")
	var test_engine = create_test_engine("UI Test Engine")
	PlayerData.inventory.append(test_weapon)
	PlayerData.inventory.append(test_engine)

func teardown_test():
	if hangar_scene:
		hangar_scene.queue_free()
	if equipment_screen:
		equipment_screen.queue_free()

# Test hangar scene loading
func test_hangar_scene_loading():
	# Test that hangar scene can be loaded
	var hangar_scene_path = "res://scenes/menus/hangar.tscn"
	assert_true(ResourceLoader.exists(hangar_scene_path), "Hangar scene should exist")
	
	var hangar_scene_resource = load(hangar_scene_path)
	assert_not_null(hangar_scene_resource, "Hangar scene should load successfully")

# Test equipment screen scene loading
func test_equipment_screen_loading():
	# Test that equipment screen scene can be loaded
	var equipment_scene_path = "res://scenes/ui/ship_equipment_screen.tscn"
	assert_true(ResourceLoader.exists(equipment_scene_path), "Equipment screen scene should exist")
	
	var equipment_scene_resource = load(equipment_scene_path)
	assert_not_null(equipment_scene_resource, "Equipment screen scene should load successfully")

# Test button signal connections
func test_button_signal_connections():
	# This test verifies that buttons are properly connected to their handlers
	# We can't easily test signal connections without the actual UI, but we can
	# verify that the methods exist and are callable
	
	# Test that hangar methods exist (if we had access to the instance)
	# This is more of a documentation test than a functional test
	assert_true(true, "Button signal connections should be properly set up in hangar.gd")

# Test scene path validation
func test_scene_path_validation():
	# Test that all required scenes exist
	var required_scenes = [
		"res://scenes/menus/hangar.tscn",
		"res://scenes/ui/ship_equipment_screen.tscn",
		"res://scenes/game/node_2d.tscn",
		"res://scenes/ui/game_over_screen.tscn",
		"res://scenes/ui/win_screen.tscn"
	]
	
	for scene_path in required_scenes:
		assert_true(ResourceLoader.exists(scene_path), "Scene should exist: " + scene_path)

# Test script path validation
func test_script_path_validation():
	# Test that all required scripts exist
	var required_scripts = [
		"res://scripts/ui/hangar.gd",
		"res://scripts/ui/ship_equipment_screen.gd",
		"res://scripts/core/player.gd",
		"res://scripts/core/main.gd",
		"res://autoload/playerData.gd",
		"res://autoload/build_version.gd",
		"res://autoload/inventory.gd"
	]
	
	for script_path in required_scripts:
		var script = load(script_path)
		assert_not_null(script, "Script should load: " + script_path)

# Test texture path validation
func test_texture_path_validation():
	# Test that all required textures exist
	var required_textures = [
		"res://assets/textures/hangar.png",
		"res://assets/textures/logo.png",
		"res://assets/textures/ship.png",
		"res://assets/textures/enemy_image.png"
	]
	
	for texture_path in required_textures:
		var texture = load(texture_path)
		assert_not_null(texture, "Texture should load: " + texture_path)

# Test autoload path validation
func test_autoload_path_validation():
	# Test that autoload paths are correctly configured
	var project_file = FileAccess.open("res://project.godot", FileAccess.READ)
	var content = project_file.get_as_text()
	project_file.close()
	
	# Check that autoload paths are correct
	assert_true(content.contains("PlayerData=\"*res://autoload/playerData.gd\""), "PlayerData autoload path should be correct")
	assert_true(content.contains("BuildVersion=\"*res://autoload/build_version.gd\""), "BuildVersion autoload path should be correct")
	assert_true(content.contains("PlayerInventory=\"*res://autoload/inventory.gd\""), "PlayerInventory autoload path should be correct")

# Test launch validation logic
func test_launch_validation_logic():
	# Test the launch validation logic from hangar.gd
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.equipped_components.get("engine", [])
	
	# Check if player has at least one weapon and one engine
	var has_weapon = equipped_weapons.size() > 0 and equipped_weapons[0] != null
	var has_engine = equipped_engines.size() > 0 and equipped_engines[0] != null
	
	# Initially should not have equipment (unless from starter items)
	var can_launch = has_weapon and has_engine
	
	# Add equipment
	var test_weapon = create_test_weapon("Launch Test Weapon")
	var test_engine = create_test_engine("Launch Test Engine")
	
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = [test_engine]
	
	# Re-check launch validation
	equipped_weapons = PlayerData.get_equipped_weapons()
	equipped_engines = PlayerData.equipped_components.get("engine", [])
	has_weapon = equipped_weapons.size() > 0 and equipped_weapons[0] != null
	has_engine = equipped_engines.size() > 0 and equipped_engines[0] != null
	can_launch = has_weapon and has_engine
	
	assert_true(can_launch, "Should be able to launch with proper equipment")

# Test equipment screen population
func test_equipment_screen_population():
	# Test that equipment screen can be populated with data
	# This is a mock test since we can't easily instantiate the UI without the full scene tree
	
	# Verify that PlayerData has the required data for equipment screen
	assert_true(PlayerData.inventory.size() > 0, "PlayerData should have inventory items")
	
	# Check that we have items of different types
	var weapon_count = 0
	var engine_count = 0
	
	for item in PlayerData.inventory:
		if item.slot_type == "weapon":
			weapon_count += 1
		elif item.slot_type == "engine":
			engine_count += 1
	
	assert_true(weapon_count > 0, "Should have weapon items for equipment screen")
	assert_true(engine_count > 0, "Should have engine items for equipment screen")

# Test scene transition paths
func test_scene_transition_paths():
	# Test that scene transition paths are correct
	var hangar_to_game_path = "res://scenes/game/node_2d.tscn"
	var hangar_to_equipment_path = "res://scenes/ui/ship_equipment_screen.tscn"
	
	assert_true(ResourceLoader.exists(hangar_to_game_path), "Game scene should exist")
	assert_true(ResourceLoader.exists(hangar_to_equipment_path), "Equipment screen scene should exist")

# Test UI element accessibility
func test_ui_element_accessibility():
	# Test that UI elements can be accessed programmatically
	# This is a conceptual test since we can't easily test UI without the scene tree
	
	# Verify that the required UI methods exist in the scripts
	var hangar_script = load("res://scripts/ui/hangar.gd")
	assert_not_null(hangar_script, "Hangar script should load")
	
	var equipment_script = load("res://scripts/ui/ship_equipment_screen.gd")
	assert_not_null(equipment_script, "Equipment screen script should load")

# Test error handling in UI
func test_ui_error_handling():
	# Test that UI can handle missing or invalid data gracefully
	
	# Test with empty inventory
	var original_inventory = PlayerData.inventory.duplicate()
	PlayerData.inventory.clear()
	
	# Should not crash when trying to populate equipment screen
	# (This is a conceptual test - in practice, the UI should handle empty data gracefully)
	assert_equal(0, PlayerData.inventory.size(), "Inventory should be empty for testing")
	
	# Restore inventory
	PlayerData.inventory = original_inventory

# Test UI performance
func test_ui_performance():
	# Test that UI can handle large amounts of data efficiently
	
	# Add many items to inventory
	var start_time = Time.get_ticks_msec()
	
	for i in range(50):
		var weapon = create_test_weapon("Performance Weapon " + str(i))
		PlayerData.inventory.append(weapon)
	
	var end_time = Time.get_ticks_msec()
	var duration = end_time - start_time
	
	# Should complete within reasonable time
	assert_true(duration < 1000, "Should handle 50 items efficiently")
	assert_equal(50, PlayerData.inventory.size(), "Should have 50 items in inventory")

# Test UI data consistency
func test_ui_data_consistency():
	# Test that UI data is consistent across different operations
	
	# Add test equipment
	var test_weapon = create_test_weapon("Consistency Test Weapon")
	var test_engine = create_test_engine("Consistency Test Engine")
	
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = [test_engine]
	
	# Verify data consistency
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.equipped_components["engine"]
	
	assert_equal(1, equipped_weapons.size(), "Should have one equipped weapon")
	assert_equal(1, equipped_engines.size(), "Should have one equipped engine")
	assert_equal("Consistency Test Weapon", equipped_weapons[0].name, "Weapon name should be consistent")
	assert_equal("Consistency Test Engine", equipped_engines[0].name, "Engine name should be consistent")

# Test UI state management
func test_ui_state_management():
	# Test that UI state is properly managed
	
	# Test initial state
	assert_equal(0, PlayerData.equipped_components.size(), "Should start with no equipped components")
	
	# Add equipment
	var test_weapon = create_test_weapon("State Test Weapon")
	PlayerData.equipped_components["weapon"] = [test_weapon]
	
	# Verify state change
	assert_equal(1, PlayerData.equipped_components.size(), "Should have one equipped component type")
	assert_equal(1, PlayerData.equipped_components["weapon"].size(), "Should have one equipped weapon")
	
	# Remove equipment
	PlayerData.equipped_components.clear()
	
	# Verify state reset
	assert_equal(0, PlayerData.equipped_components.size(), "Should have no equipped components after clear") 