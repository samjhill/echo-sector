extends BaseTestSuite
class_name EquipmentSystemTestSuite

var equipment_screen: ShipEquipmentScreen

func setup_test():
	# Create a mock equipment screen for testing
	equipment_screen = ShipEquipmentScreen.new()
	
	# Set up test data
	PlayerData.load_game()
	
	# Add some test items to inventory
	var test_weapon = create_test_weapon("Test Laser")
	var test_engine = create_test_engine("Test Engine")
	PlayerData.inventory.append(test_weapon)
	PlayerData.inventory.append(test_engine)

func teardown_test():
	if equipment_screen:
		equipment_screen.queue_free()

# Test equipment screen initialization
func test_equipment_screen_initialization():
	assert_not_null(equipment_screen, "Equipment screen should be created")
	assert_true(equipment_screen is ShipEquipmentScreen, "Should be of type ShipEquipmentScreen")

# Test inventory filtering by slot type
func test_inventory_filtering():
	# Test weapon filtering
	var weapon_items = []
	for item in PlayerData.inventory:
		if item.slot_type == "weapon":
			weapon_items.append(item)
	
	assert_true(weapon_items.size() > 0, "Should have weapon items in inventory")
	
	# Test engine filtering
	var engine_items = []
	for item in PlayerData.inventory:
		if item.slot_type == "engine":
			engine_items.append(item)
	
	assert_true(engine_items.size() > 0, "Should have engine items in inventory")

# Test equipment slot management
func test_equipment_slot_management():
	# Test weapon slot
	var weapon = null
	for item in PlayerData.inventory:
		if item.slot_type == "weapon":
			weapon = item
			break
	
	assert_not_null(weapon, "Should have a weapon to equip")
	
	# Equip weapon
	if not PlayerData.equipped_components.has("weapon"):
		PlayerData.equipped_components["weapon"] = []
	PlayerData.equipped_components["weapon"].append(weapon)
	
	# Verify weapon is equipped
	var equipped_weapons = PlayerData.get_equipped_weapons()
	assert_equal(1, equipped_weapons.size(), "Should have one equipped weapon")
	assert_equal(weapon.name, equipped_weapons[0].name, "Equipped weapon should match")

# Test engine slot management
func test_engine_slot_management():
	# Test engine slot
	var engine = null
	for item in PlayerData.inventory:
		if item.slot_type == "engine":
			engine = item
			break
	
	assert_not_null(engine, "Should have an engine to equip")
	
	# Equip engine
	if not PlayerData.equipped_components.has("engine"):
		PlayerData.equipped_components["engine"] = []
	PlayerData.equipped_components["engine"].append(engine)
	
	# Verify engine is equipped
	var equipped_engines = PlayerData.equipped_components["engine"]
	assert_equal(1, equipped_engines.size(), "Should have one equipped engine")
	assert_equal(engine.name, equipped_engines[0].name, "Equipped engine should match")

# Test equipment validation
func test_equipment_validation():
	# Test that equipped items have required properties
	var test_weapon = create_test_weapon("Validation Test Weapon")
	
	assert_true(test_weapon.name != "", "Weapon should have a name")
	assert_true(test_weapon.description != "", "Weapon should have a description")
	assert_equal("weapon", test_weapon.slot_type, "Weapon should have correct slot type")
	assert_true(test_weapon is Item, "Weapon should be an Item")
	
	var test_engine = create_test_engine("Validation Test Engine")
	
	assert_true(test_engine.name != "", "Engine should have a name")
	assert_true(test_engine.description != "", "Engine should have a description")
	assert_equal("engine", test_engine.slot_type, "Engine should have correct slot type")
	assert_true(test_engine is Item, "Engine should be an Item")

# Test equipment serialization
func test_equipment_serialization():
	# Set up test equipment
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

# Test equipment slot limits
func test_equipment_slot_limits():
	# Test that we can equip multiple items in the same slot type
	var weapon1 = create_test_weapon("Weapon 1")
	var weapon2 = create_test_weapon("Weapon 2")
	
	PlayerData.equipped_components["weapon"] = [weapon1, weapon2]
	
	var equipped_weapons = PlayerData.get_equipped_weapons()
	assert_equal(2, equipped_weapons.size(), "Should have two equipped weapons")
	assert_equal("Weapon 1", equipped_weapons[0].name, "First weapon should be correct")
	assert_equal("Weapon 2", equipped_weapons[1].name, "Second weapon should be correct")

# Test equipment removal
func test_equipment_removal():
	# Set up test equipment
	var test_weapon = create_test_weapon("Removal Test Weapon")
	PlayerData.equipped_components["weapon"] = [test_weapon]
	
	# Verify weapon is equipped
	var equipped_weapons = PlayerData.get_equipped_weapons()
	assert_equal(1, equipped_weapons.size(), "Should have one equipped weapon")
	
	# Remove weapon
	PlayerData.equipped_components["weapon"].clear()
	
	# Verify weapon is removed
	equipped_weapons = PlayerData.get_equipped_weapons()
	assert_equal(0, equipped_weapons.size(), "Should have no equipped weapons")

# Test equipment validation for launch
func test_launch_validation():
	# Test launch validation with no equipment
	var has_weapon = PlayerData.get_equipped_weapons().size() > 0
	var has_engine = PlayerData.equipped_components.has("engine") and PlayerData.equipped_components["engine"].size() > 0
	
	# Initially should not have equipment (unless from starter items)
	var can_launch = has_weapon and has_engine
	
	# Add equipment
	var test_weapon = create_test_weapon("Launch Test Weapon")
	var test_engine = create_test_engine("Launch Test Engine")
	
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = [test_engine]
	
	# Verify launch validation
	has_weapon = PlayerData.get_equipped_weapons().size() > 0
	has_engine = PlayerData.equipped_components.has("engine") and PlayerData.equipped_components["engine"].size() > 0
	can_launch = has_weapon and has_engine
	
	assert_true(can_launch, "Should be able to launch with proper equipment")

# Test equipment data integrity
func test_equipment_data_integrity():
	var test_weapon = create_test_weapon("Integrity Test Weapon")
	test_weapon.damage = 25
	test_weapon.cooldown = 0.5
	
	PlayerData.equipped_components["weapon"] = [test_weapon]
	
	# Save and reload
	PlayerData.save_game()
	PlayerData.equipped_components.clear()
	PlayerData.load_game()
	
	# Verify data integrity
	var equipped_weapons = PlayerData.get_equipped_weapons()
	assert_equal(1, equipped_weapons.size(), "Should have one equipped weapon")
	
	var equipped_weapon = equipped_weapons[0]
	assert_equal("Integrity Test Weapon", equipped_weapon.name, "Weapon name should be preserved")
	assert_equal(25, equipped_weapon.damage, "Weapon damage should be preserved")
	assert_equal(0.5, equipped_weapon.cooldown, "Weapon cooldown should be preserved")

# Test equipment compatibility
func test_equipment_compatibility():
	# Test that different item types can coexist
	var weapon = create_test_weapon("Compatibility Weapon")
	var engine = create_test_engine("Compatibility Engine")
	
	PlayerData.equipped_components["weapon"] = [weapon]
	PlayerData.equipped_components["engine"] = [engine]
	
	# Verify both can be equipped simultaneously
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.equipped_components["engine"]
	
	assert_equal(1, equipped_weapons.size(), "Should have one equipped weapon")
	assert_equal(1, equipped_engines.size(), "Should have one equipped engine")
	assert_true(equipped_weapons[0] is LaserWeapon, "Equipped weapon should be correct type")
	assert_true(equipped_engines[0] is EngineComponent, "Equipped engine should be correct type")

# Test equipment error handling
func test_equipment_error_handling():
	# Test handling of null items
	PlayerData.equipped_components["weapon"] = [null, create_test_weapon("Valid Weapon")]
	
	# Call cleanup
	PlayerData.cleanup_null_items()
	
	# Verify null items were removed
	var equipped_weapons = PlayerData.get_equipped_weapons()
	assert_equal(1, equipped_weapons.size(), "Should have only valid weapons after cleanup")
	assert_equal("Valid Weapon", equipped_weapons[0].name, "Valid weapon should remain")

# Test equipment performance
func test_equipment_performance():
	# Test that equipment system can handle many items efficiently
	var start_time = Time.get_ticks_msec()
	
	# Add many test items
	for i in range(100):
		var weapon = create_test_weapon("Performance Weapon " + str(i))
		PlayerData.inventory.append(weapon)
	
	var end_time = Time.get_ticks_msec()
	var duration = end_time - start_time
	
	# Should complete within reasonable time (less than 1 second)
	assert_true(duration < 1000, "Should handle 100 items efficiently")
	assert_equal(100, PlayerData.inventory.size(), "Should have 100 items in inventory") 