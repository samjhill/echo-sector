extends BaseTestSuite
class_name LaunchValidationTestSuite

var hangar_scene: Control

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

# Test launch validation logic
func test_launch_validation_no_equipment():
	"""Test that launch validation detects missing equipment correctly"""
	# Clear all equipment
	PlayerData.equipped_components["weapon"] = []
	PlayerData.equipped_components["engine"] = []
	
	# Test the validation logic (same as in hangar.gd)
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
	
	# Should detect missing equipment
	assert_false(has_weapon, "Should not have any weapons equipped")
	assert_false(has_engine, "Should not have any engines equipped")
	assert_false(has_weapon and has_engine, "Should detect missing equipment")

func test_launch_validation_with_equipment():
	"""Test that launch validation passes when proper equipment is equipped"""
	# Equip a weapon and engine
	var test_weapon = create_test_weapon("Test Weapon")
	var test_engine = create_test_engine("Test Engine")
	
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = [test_engine]
	
	# Test the validation logic (same as in hangar.gd)
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
	
	# Should pass validation
	assert_true(has_weapon, "Should have weapons equipped")
	assert_true(has_engine, "Should have engines equipped")
	assert_true(has_weapon and has_engine, "Should pass validation with proper equipment")

func test_launch_validation_partial_equipment():
	"""Test that launch validation detects partial equipment correctly"""
	# Equip only a weapon, no engine
	var test_weapon = create_test_weapon("Test Weapon")
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = []
	
	# Test the validation logic (same as in hangar.gd)
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
	
	# Should detect partial equipment
	assert_true(has_weapon, "Should have weapons equipped")
	assert_false(has_engine, "Should not have engines equipped")
	assert_false(has_weapon and has_engine, "Should detect partial equipment")

func test_launch_validation_null_items():
	"""Test that null items in equipment arrays are handled correctly"""
	# Add null items to equipment arrays
	PlayerData.equipped_components["weapon"] = [null, null]
	PlayerData.equipped_components["engine"] = [null]
	
	# Test the validation logic (same as in hangar.gd)
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
	
	# Should detect missing equipment (null items)
	assert_false(has_weapon, "Should not have any valid weapons equipped")
	assert_false(has_engine, "Should not have any valid engines equipped")
	assert_false(has_weapon and has_engine, "Should detect missing equipment with null items")

func test_launch_validation_edge_cases():
	"""Test launch validation edge cases"""
	# Test with empty arrays
	PlayerData.equipped_components["weapon"] = []
	PlayerData.equipped_components["engine"] = []
	
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
	
	# Should detect missing equipment
	assert_false(has_weapon, "Should not have any weapons equipped")
	assert_false(has_engine, "Should not have any engines equipped")
	assert_false(has_weapon and has_engine, "Should detect missing equipment with empty arrays")
	
	# Test with missing equipment keys
	PlayerData.equipped_components.erase("weapon")
	PlayerData.equipped_components.erase("engine")
	
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
	
	# Should detect missing equipment
	assert_false(has_weapon, "Should not have any weapons equipped")
	assert_false(has_engine, "Should not have any engines equipped")
	assert_false(has_weapon and has_engine, "Should detect missing equipment with missing keys")

func test_launch_validation_multiple_items():
	"""Test launch validation with multiple equipped items"""
	# Equip multiple weapons and engines
	var test_weapon1 = create_test_weapon("Weapon 1")
	var test_weapon2 = create_test_weapon("Weapon 2")
	var test_engine1 = create_test_engine("Engine 1")
	var test_engine2 = create_test_engine("Engine 2")
	
	PlayerData.equipped_components["weapon"] = [test_weapon1, test_weapon2]
	PlayerData.equipped_components["engine"] = [test_engine1, test_engine2]
	
	# Test the validation logic (same as in hangar.gd)
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
	
	# Should pass validation
	assert_true(has_weapon, "Should have weapons equipped")
	assert_true(has_engine, "Should have engines equipped")
	assert_true(has_weapon and has_engine, "Should pass validation with multiple items")

func test_launch_validation_mixed_null_valid():
	"""Test launch validation with mixed null and valid items"""
	# Equip valid weapon, null engine
	var test_weapon = create_test_weapon("Test Weapon")
	PlayerData.equipped_components["weapon"] = [test_weapon]
	PlayerData.equipped_components["engine"] = [null]
	
	# Test the validation logic (same as in hangar.gd)
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
	
	# Should detect partial equipment (no valid engine)
	assert_true(has_weapon, "Should have weapons equipped")
	assert_false(has_engine, "Should not have valid engines equipped")
	assert_false(has_weapon and has_engine, "Should detect partial equipment with mixed null/valid items")

func test_equipment_notification_logic():
	"""Test the equipment notification logic in the equipment screen"""
	# Test with missing equipment
	PlayerData.equipped_components["weapon"] = []
	PlayerData.equipped_components["engine"] = []
	
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
	
	# Should trigger notification
	assert_false(has_weapon, "Should not have weapons equipped")
	assert_false(has_engine, "Should not have engines equipped")
	assert_true(not has_weapon or not has_engine, "Should trigger equipment notification") 