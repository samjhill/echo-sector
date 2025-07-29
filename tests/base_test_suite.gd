extends RefCounted
class_name BaseTestSuite

# Common test utilities
var test_runner: TestRunner

func _init():
	test_runner = TestRunner.new()

# Setup and teardown methods that can be overridden
func setup_test():
	# Override in subclasses for test-specific setup
	pass

func teardown_test():
	# Override in subclasses for test-specific cleanup
	pass

# Assertion methods
func assert_true(condition, message = ""):
	return test_runner.assert_true(condition, message)

func assert_false(condition, message = ""):
	return test_runner.assert_false(condition, message)

func assert_equal(expected, actual, message = ""):
	return test_runner.assert_equal(expected, actual, message)

func assert_not_null(value, message = ""):
	return test_runner.assert_not_null(value, message)

func assert_null(value, message = ""):
	return test_runner.assert_null(value, message)

# Utility methods for tests
func create_temp_save_file():
	# Create a temporary save file for testing
	var temp_data = {
		"credits": 100,
		"scrap": 50,
		"inventory": [],
		"equipment": {}
	}
	
	var temp_file = FileAccess.open("user://temp_save.json", FileAccess.WRITE)
	temp_file.store_string(JSON.stringify(temp_data))
	temp_file.close()
	
	return "user://temp_save.json"

func cleanup_temp_save_file():
	# Clean up temporary save file
	if FileAccess.file_exists("user://temp_save.json"):
		DirAccess.remove_absolute("user://temp_save.json")

func create_test_item(name = "Test Item", slot_type = "weapon"):
	# Create a test item for testing
	var item = Item.new()
	item.name = name
	item.description = "Test item for testing"
	item.slot_type = slot_type
	item.stats = {"damage": 10}
	return item

func create_test_weapon(name = "Test Weapon"):
	# Create a test weapon
	var weapon = LaserWeapon.new()
	weapon.name = name
	weapon.description = "Test weapon for testing"
	weapon.slot_type = "weapon"
	weapon.damage = 15
	weapon.cooldown = 1.0
	return weapon

func create_test_engine(name = "Test Engine"):
	# Create a test engine
	var engine = EngineComponent.new()
	engine.name = name
	engine.description = "Test engine for testing"
	engine.slot_type = "engine"
	engine.move_speed_bonus = 150.0
	engine.rotation_speed_bonus = 2.5
	return engine 