extends MainLoop
class_name ComprehensiveTestRunner

# Test suites
var test_suites: Array[BaseTestSuite] = []
var total_tests = 0
var passed_tests = 0
var failed_tests = 0
var start_time: float

func _initialize():
	Logger.info("Starting Comprehensive Test Suite", "TestRunner")
	start_time = Time.get_unix_time_from_system()
	
	# Initialize test suites
	_setup_test_suites()
	
	# Run all tests
	_run_all_tests()
	
	# Print results
	_print_results()
	
	# Exit with appropriate code
	if failed_tests > 0:
		Logger.error("Test suite failed with %d failures" % failed_tests, "TestRunner")
		return 1
	else:
		Logger.info("All tests passed!", "TestRunner")
		return 0

func _setup_test_suites():
	"""Setup all test suites"""
	# Core system tests
	test_suites.append(PlayerDataTestSuite.new())
	test_suites.append(ResourceLoadingTestSuite.new())
	test_suites.append(EquipmentSystemTestSuite.new())
	test_suites.append(EquipmentValidationTestSuite.new())
	test_suites.append(LaunchValidationTestSuite.new())
	
	# Stellar Grid tests
	test_suites.append(StellarGridTestSuite.new())
	
	# UI tests
	test_suites.append(UITestSuite.new())

func _run_all_tests():
	"""Run all test suites"""
	for test_suite in test_suites:
		_run_test_suite(test_suite)

func _run_test_suite(test_suite: BaseTestSuite):
	"""Run a single test suite"""
	var suite_name = test_suite.get_class()
	Logger.info("Running test suite: %s" % suite_name, "TestRunner")
	
	# Get all test methods
	var test_methods = _get_test_methods(test_suite)
	
	for method_name in test_methods:
		_run_single_test(test_suite, method_name)

func _get_test_methods(test_suite: BaseTestSuite) -> Array[String]:
	"""Get all test methods from a test suite"""
	var methods: Array[String] = []
	var script = test_suite.get_script()
	
	if script:
		var method_list = script.get_script_method_list()
		for method_info in method_list:
			var method_name = method_info.name
			if method_name.begins_with("test_"):
				methods.append(method_name)
	
	return methods

func _run_single_test(test_suite: BaseTestSuite, method_name: String):
	"""Run a single test method"""
	total_tests += 1
	
	# Setup test
	test_suite.setup_test()
	
	# Run test
	var start_time = Time.get_unix_time_from_system()
	var success = false
	var error_message = ""
	
	try:
		# Call the test method
		test_suite.call(method_name)
		success = true
	except:
		error_message = "Exception occurred: " + str(get_exception())
	
	var end_time = Time.get_unix_time_from_system()
	var duration = end_time - start_time
	
	# Teardown test
	test_suite.teardown_test()
	
	# Check results
	if success and test_suite.passed_tests > 0 and test_suite.failed_tests == 0:
		passed_tests += 1
		Logger.info("✓ %s.%s (%.3fs)" % [test_suite.get_class(), method_name, duration], "TestRunner")
	else:
		failed_tests += 1
		Logger.error("✗ %s.%s (%.3fs) - %s" % [test_suite.get_class(), method_name, duration, error_message], "TestRunner")

func _print_results():
	"""Print comprehensive test results"""
	var end_time = Time.get_unix_time_from_system()
	var total_duration = end_time - start_time
	
	print("\n" + "=".repeat(60))
	print("COMPREHENSIVE TEST RESULTS")
	print("=".repeat(60))
	print("Total Tests: %d" % total_tests)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % failed_tests)
	print("Success Rate: %.1f%%" % (float(passed_tests) / total_tests * 100.0))
	print("Duration: %.3fs" % total_duration)
	print("=".repeat(60))
	
	if failed_tests > 0:
		print("❌ Some tests failed!")
		print("Check the logs above for details.")
	else:
		print("🎉 All tests passed!")
		print("Code quality is excellent!")
	
	print("=".repeat(60))

# Test suite implementations
class PlayerDataTestSuite extends BaseTestSuite:
	func test_save_load_functionality():
		"""Test PlayerData save/load functionality"""
		# Test new game creation
		PlayerData.load_game()
		assert_true(PlayerData.credits >= 0, "Credits should be non-negative")
		assert_true(PlayerData.scrap >= 0, "Scrap should be non-negative")
		
		# Test inventory initialization
		assert_true(PlayerData.inventory is Array, "Inventory should be an array")
		
		# Test equipment initialization
		assert_true(PlayerData.equipped_components is Dictionary, "Equipped components should be a dictionary")
	
	func test_resource_management():
		"""Test resource management functions"""
		var original_credits = PlayerData.credits
		var original_scrap = PlayerData.scrap
		
		# Test adding resources
		PlayerData.add_credits(10)
		assert_equal(PlayerData.credits, original_credits + 10, "Credits should be added correctly")
		
		PlayerData.add_scrap(5)
		assert_equal(PlayerData.scrap, original_scrap + 5, "Scrap should be added correctly")
	
	func test_inventory_management():
		"""Test inventory management functions"""
		var test_item = create_test_item("Test Item")
		var original_size = PlayerData.inventory.size()
		
		# Test adding item
		PlayerData.add_item_to_inventory(test_item)
		assert_equal(PlayerData.inventory.size(), original_size + 1, "Inventory size should increase")
		
		# Test removing item
		PlayerData.remove_item_from_inventory(test_item)
		assert_equal(PlayerData.inventory.size(), original_size, "Inventory size should return to original")

class ResourceLoadingTestSuite extends BaseTestSuite:
	func test_core_scripts_load():
		"""Test that core scripts load correctly"""
		var scripts = [
			"res://scripts/core/item.gd",
			"res://scripts/core/grid_manager.gd",
			"res://scripts/core/grid_tile.gd"
		]
		
		for script_path in scripts:
			var script = load(script_path)
			assert_not_null(script, "Script should load: %s" % script_path)
	
	func test_ui_scripts_load():
		"""Test that UI scripts load correctly"""
		var scripts = [
			"res://scripts/ui/hangar.gd",
			"res://scripts/ui/stellar_grid_ui.gd",
			"res://scripts/ui/ship_equipment_screen.gd"
		]
		
		for script_path in scripts:
			var script = load(script_path)
			assert_not_null(script, "Script should load: %s" % script_path)
	
	func test_scenes_load():
		"""Test that scenes load correctly"""
		var scenes = [
			"res://scenes/menus/hangar.tscn",
			"res://scenes/ui/stellar_grid_screen.tscn",
			"res://scenes/ui/ship_equipment_screen.tscn"
		]
		
		for scene_path in scenes:
			var scene = load(scene_path)
			assert_not_null(scene, "Scene should load: %s" % scene_path)

class EquipmentSystemTestSuite extends BaseTestSuite:
	func test_weapon_creation():
		"""Test weapon creation and properties"""
		var weapon = create_test_weapon("Test Laser")
		assert_not_null(weapon, "Weapon should be created")
		assert_equal(weapon.name, "Test Laser", "Weapon should have correct name")
		assert_true(weapon.has_method("get_damage"), "Weapon should have damage method")
	
	func test_engine_creation():
		"""Test engine creation and properties"""
		var engine = create_test_engine("Test Engine")
		assert_not_null(engine, "Engine should be created")
		assert_equal(engine.name, "Test Engine", "Engine should have correct name")
	
	func test_equipment_equipping():
		"""Test equipment equipping system"""
		var weapon = create_test_weapon("Test Weapon")
		var engine = create_test_engine("Test Engine")
		
		# Test equipping weapons
		var equipped_weapons = PlayerData.get_equipped_weapons()
		assert_true(equipped_weapons is Array, "Equipped weapons should be an array")
		
		# Test equipping engines
		var equipped_engines = PlayerData.get_equipped_engines()
		assert_true(equipped_engines is Array, "Equipped engines should be an array")

class UITestSuite extends BaseTestSuite:
	func test_hangar_ui_components():
		"""Test hangar UI component loading"""
		var hangar_scene = load("res://scenes/menus/hangar.tscn")
		assert_not_null(hangar_scene, "Hangar scene should load")
		
		var hangar_instance = hangar_scene.instantiate()
		assert_not_null(hangar_instance, "Hangar should instantiate")
		
		# Test that key components exist
		var script = hangar_instance.get_script()
		assert_not_null(script, "Hangar should have a script")
		
		hangar_instance.queue_free()
	
	func test_stellar_grid_ui_components():
		"""Test stellar grid UI component loading"""
		var grid_scene = load("res://scenes/ui/stellar_grid_screen.tscn")
		assert_not_null(grid_scene, "Stellar grid scene should load")
		
		var grid_instance = grid_scene.instantiate()
		assert_not_null(grid_instance, "Stellar grid should instantiate")
		
		grid_instance.queue_free()
	
	func test_equipment_screen_ui_components():
		"""Test equipment screen UI component loading"""
		var equipment_scene = load("res://scenes/ui/ship_equipment_screen.tscn")
		assert_not_null(equipment_scene, "Equipment screen scene should load")
		
		var equipment_instance = equipment_scene.instantiate()
		assert_not_null(equipment_instance, "Equipment screen should instantiate")
		
		equipment_instance.queue_free()

# Utility functions for testing
func get_exception() -> String:
	"""Get the current exception information"""
	# This is a simplified version - in a real implementation,
	# you'd want to capture the actual exception details
	return "Test failed"

# Main execution
func _ready():
	# This would be called if running as a scene
	_initialize() 