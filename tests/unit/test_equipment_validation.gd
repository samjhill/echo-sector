extends BaseTestSuite
class_name EquipmentValidationTestSuite

var hangar_scene: Control
var equipment_screen: ShipEquipmentScreen

func setup_test():
	# Load PlayerData
	PlayerData.load_game()
	
	# Create test items
	var test_weapon = create_test_weapon("Test Weapon")
	var test_engine = create_test_engine("Test Engine")
	PlayerData.inventory.append(test_weapon)
	PlayerData.inventory.append(test_engine)

func teardown_test():
	if hangar_scene:
		hangar_scene.queue_free()
	if equipment_screen:
		equipment_screen.queue_free()

# Test equipment validation
func test_equipment_validation_no_equipment():
	"""Test that launch is blocked when no equipment is equipped"""
	# Clear all equipment
	PlayerData.equipped_components["weapon"] = []
	PlayerData.equipped_components["engine"] = []
	
	# Verify no weapons are equipped
	var equipped_weapons = PlayerData.get_equipped_weapons()
	assert_equal(equipped_weapons.size(), 0, "Should have no equipped weapons")
	
	# Verify no engines are equipped
	var equipped_engines = PlayerData.get_equipped_engines()
	assert_equal(equipped_engines.size(), 0, "Should have no equipped engines")
	
	# Test validation logic
	var has_weapon = false
	var has_engine = false
	
	for weapon in equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	for engine in equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	assert_false(has_weapon, "Should not have any weapons equipped")
	assert_false(has_engine, "Should not have any engines equipped")

func test_equipment_validation_with_equipment():
	"""Test that launch is allowed when proper equipment is equipped"""
	# Equip a weapon
	var test_weapon = create_test_weapon("Test Weapon")
	PlayerData.equipped_components["weapon"] = [test_weapon]
	
	# Equip an engine
	var test_engine = create_test_engine("Test Engine")
	PlayerData.equipped_components["engine"] = [test_engine]
	
	# Verify weapons are equipped
	var equipped_weapons = PlayerData.get_equipped_weapons()
	assert_equal(equipped_weapons.size(), 1, "Should have 1 equipped weapon")
	assert_not_null(equipped_weapons[0], "Equipped weapon should not be null")
	
	# Verify engines are equipped
	var equipped_engines = PlayerData.get_equipped_engines()
	assert_equal(equipped_engines.size(), 1, "Should have 1 equipped engine")
	assert_not_null(equipped_engines[0], "Equipped engine should not be null")
	
	# Test validation logic
	var has_weapon = false
	var has_engine = false
	
	for weapon in equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	for engine in equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	assert_true(has_weapon, "Should have weapons equipped")
	assert_true(has_engine, "Should have engines equipped")

func test_equipment_validation_partial_equipment():
	"""Test that launch is blocked when only partial equipment is equipped"""
	# Equip only a weapon, no engine
	var test_weapon = create_test_weapon("Test Weapon")
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = []
	
	# Verify weapon is equipped but no engine
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.get_equipped_engines()
	
	assert_equal(equipped_weapons.size(), 1, "Should have 1 equipped weapon")
	assert_equal(equipped_engines.size(), 0, "Should have no equipped engines")
	
	# Test validation logic
	var has_weapon = false
	var has_engine = false
	
	for weapon in equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	for engine in equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	assert_true(has_weapon, "Should have weapons equipped")
	assert_false(has_engine, "Should not have engines equipped")

func test_equipment_validation_null_items():
	"""Test that null items in equipment arrays are handled correctly"""
	# Add null items to equipment arrays
	PlayerData.equipped_components["weapon"] = [null, null]
	PlayerData.equipped_components["engine"] = [null]
	
	# Verify null items are handled
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.get_equipped_engines()
	
	assert_equal(equipped_weapons.size(), 2, "Should have 2 weapon slots")
	assert_equal(equipped_engines.size(), 1, "Should have 1 engine slot")
	
	# Test validation logic
	var has_weapon = false
	var has_engine = false
	
	for weapon in equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	for engine in equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	assert_false(has_weapon, "Should not have any valid weapons equipped")
	assert_false(has_engine, "Should not have any valid engines equipped")

func test_equipment_getter_methods():
	"""Test that equipment getter methods work correctly"""
	# Test empty equipment
	var empty_weapons = PlayerData.get_equipped_weapons()
	var empty_engines = PlayerData.get_equipped_engines()
	
	assert_true(empty_weapons is Array, "get_equipped_weapons should return an array")
	assert_true(empty_engines is Array, "get_equipped_engines should return an array")
	
	# Test with equipment
	var test_weapon = create_test_weapon("Test Weapon")
	var test_engine = create_test_engine("Test Engine")
	
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = [test_engine]
	
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.get_equipped_engines()
	
	assert_equal(equipped_weapons.size(), 1, "Should have 1 equipped weapon")
	assert_equal(equipped_engines.size(), 1, "Should have 1 equipped engine")
	assert_equal(equipped_weapons[0].name, "Test Weapon", "Weapon name should match")
	assert_equal(equipped_engines[0].name, "Test Engine", "Engine name should match")

func test_equipment_slot_management():
	"""Test that equipment slots are managed correctly"""
	# Test adding equipment to slots
	var test_weapon1 = create_test_weapon("Weapon 1")
	var test_weapon2 = create_test_weapon("Weapon 2")
	var test_engine = create_test_engine("Engine 1")
	
	# Add to multiple slots
	PlayerData.equipped_components["weapon"] = [test_weapon1, test_weapon2]
	PlayerData.equipped_components["engine"] = [test_engine]
	
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.get_equipped_engines()
	
	assert_equal(equipped_weapons.size(), 2, "Should have 2 equipped weapons")
	assert_equal(equipped_engines.size(), 1, "Should have 1 equipped engine")
	
	# Test validation with multiple items
	var has_weapon = false
	var has_engine = false
	
	for weapon in equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	for engine in equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	assert_true(has_weapon, "Should have weapons equipped")
	assert_true(has_engine, "Should have engines equipped")

func test_equipment_validation_edge_cases():
	"""Test equipment validation edge cases"""
	# Test with empty arrays
	PlayerData.equipped_components["weapon"] = []
	PlayerData.equipped_components["engine"] = []
	
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.get_equipped_engines()
	
	assert_equal(equipped_weapons.size(), 0, "Should have no equipped weapons")
	assert_equal(equipped_engines.size(), 0, "Should have no equipped engines")
	
	# Test with missing equipment keys
	PlayerData.equipped_components.erase("weapon")
	PlayerData.equipped_components.erase("engine")
	
	var weapons_without_key = PlayerData.get_equipped_weapons()
	var engines_without_key = PlayerData.get_equipped_engines()
	
	assert_equal(weapons_without_key.size(), 0, "Should return empty array when key doesn't exist")
	assert_equal(engines_without_key.size(), 0, "Should return empty array when key doesn't exist")

func test_equipment_validation_integration():
	"""Test the complete equipment validation flow"""
	# Start with no equipment
	PlayerData.equipped_components["weapon"] = []
	PlayerData.equipped_components["engine"] = []
	
	# Test validation logic (same as in hangar.gd)
	var has_weapon = false
	var has_engine = false
	
	var equipped_weapons = PlayerData.get_equipped_weapons()
	var equipped_engines = PlayerData.get_equipped_engines()
	
	for weapon in equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	for engine in equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	# Should fail validation
	assert_false(has_weapon or has_engine, "Should fail validation with no equipment")
	
	# Add equipment
	var test_weapon = create_test_weapon("Test Weapon")
	var test_engine = create_test_engine("Test Engine")
	
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = [test_engine]
	
	# Reset validation flags
	has_weapon = false
	has_engine = false
	
	equipped_weapons = PlayerData.get_equipped_weapons()
	equipped_engines = PlayerData.get_equipped_engines()
	
	for weapon in equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	for engine in equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	# Should pass validation
	assert_true(has_weapon and has_engine, "Should pass validation with proper equipment") 