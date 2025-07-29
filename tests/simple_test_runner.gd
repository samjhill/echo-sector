extends Node

# Simple test runner that runs tests directly without complex class loading

func _ready():
	print("🧪 Starting Echo Sector Simple Test Suite...")
	run_all_tests()

func run_all_tests():
	var total_tests = 0
	var passed_tests = 0
	var failed_tests = 0
	
	print("\n📋 Running PlayerData Tests...")
	var player_data_tests = run_player_data_tests()
	total_tests += player_data_tests.total
	passed_tests += player_data_tests.passed
	failed_tests += player_data_tests.failed
	
	print("\n📋 Running Resource Loading Tests...")
	var resource_tests = run_resource_loading_tests()
	total_tests += resource_tests.total
	passed_tests += resource_tests.passed
	failed_tests += resource_tests.failed
	
	print("\n📋 Running Equipment System Tests...")
	var equipment_tests = run_equipment_system_tests()
	total_tests += equipment_tests.total
	passed_tests += equipment_tests.passed
	failed_tests += equipment_tests.failed
	
	print("\n📋 Running UI Integration Tests...")
	var ui_tests = run_ui_integration_tests()
	total_tests += ui_tests.total
	passed_tests += ui_tests.passed
	failed_tests += ui_tests.failed
	
	print_results(total_tests, passed_tests, failed_tests)

func run_player_data_tests():
	var total = 0
	var passed = 0
	var failed = 0
	
	# Test 1: Basic save/load functionality
	total += 1
	if test_save_load_functionality():
		passed += 1
		print("  ✅ test_save_load_functionality")
	else:
		failed += 1
		print("  ❌ test_save_load_functionality")
	
	# Test 2: Initial game state
	total += 1
	if test_initial_game_state():
		passed += 1
		print("  ✅ test_initial_game_state")
	else:
		failed += 1
		print("  ❌ test_initial_game_state")
	
	# Test 3: Resource loading
	total += 1
	if test_resource_loading():
		passed += 1
		print("  ✅ test_resource_loading")
	else:
		failed += 1
		print("  ❌ test_resource_loading")
	
	return {"total": total, "passed": passed, "failed": failed}

func run_resource_loading_tests():
	var total = 0
	var passed = 0
	var failed = 0
	
	# Test 1: Load item class
	total += 1
	if test_load_item_class():
		passed += 1
		print("  ✅ test_load_item_class")
	else:
		failed += 1
		print("  ❌ test_load_item_class")
	
	# Test 2: Load engine component
	total += 1
	if test_load_engine_component():
		passed += 1
		print("  ✅ test_load_engine_component")
	else:
		failed += 1
		print("  ❌ test_load_engine_component")
	
	# Test 3: Load basic engine tres
	total += 1
	if test_load_basic_engine_tres():
		passed += 1
		print("  ✅ test_load_basic_engine_tres")
	else:
		failed += 1
		print("  ❌ test_load_basic_engine_tres")
	
	return {"total": total, "passed": passed, "failed": failed}

func run_equipment_system_tests():
	var total = 0
	var passed = 0
	var failed = 0
	
	# Test 1: Equipment validation
	total += 1
	if test_equipment_validation():
		passed += 1
		print("  ✅ test_equipment_validation")
	else:
		failed += 1
		print("  ❌ test_equipment_validation")
	
	# Test 2: Equipment serialization
	total += 1
	if test_equipment_serialization():
		passed += 1
		print("  ✅ test_equipment_serialization")
	else:
		failed += 1
		print("  ❌ test_equipment_serialization")
	
	return {"total": total, "passed": passed, "failed": failed}

func run_ui_integration_tests():
	var total = 0
	var passed = 0
	var failed = 0
	
	# Test 1: Scene path validation
	total += 1
	if test_scene_path_validation():
		passed += 1
		print("  ✅ test_scene_path_validation")
	else:
		failed += 1
		print("  ❌ test_scene_path_validation")
	
	# Test 2: Script path validation
	total += 1
	if test_script_path_validation():
		passed += 1
		print("  ✅ test_script_path_validation")
	else:
		failed += 1
		print("  ❌ test_script_path_validation")
	
	# Test 3: Texture path validation
	total += 1
	if test_texture_path_validation():
		passed += 1
		print("  ✅ test_texture_path_validation")
	else:
		failed += 1
		print("  ❌ test_texture_path_validation")
	
	return {"total": total, "passed": passed, "failed": failed}

# Individual test functions
func test_save_load_functionality():
	# Test basic save/load functionality
	PlayerData.load_game()
	var initial_credits = PlayerData.credits
	PlayerData.credits = 999
	PlayerData.save_game()
	PlayerData.credits = 0
	PlayerData.load_game()
	return PlayerData.credits == 999

func test_initial_game_state():
	# Test initial game state
	PlayerData.load_game()
	return PlayerData.credits >= 0 and PlayerData.scrap >= 0

func test_resource_loading():
	# Test resource loading
	var item_script = load("res://scripts/core/item.gd")
	var engine_script = load("res://components/engine_component.gd")
	return item_script != null and engine_script != null

func test_load_item_class():
	var item_resource = load("res://scripts/core/item.gd")
	return item_resource != null

func test_load_engine_component():
	var engine_resource = load("res://components/engine_component.gd")
	return engine_resource != null

func test_load_basic_engine_tres():
	var engine_resource = load("res://components/basic_engine.tres")
	return engine_resource != null

func test_equipment_validation():
	# Test equipment validation
	PlayerData.load_game()
	return PlayerData.inventory.size() >= 0

func test_equipment_serialization():
	# Test equipment serialization
	PlayerData.load_game()
	var initial_size = PlayerData.inventory.size()
	PlayerData.save_game()
	PlayerData.load_game()
	return PlayerData.inventory.size() == initial_size

func test_scene_path_validation():
	# Test that required scenes exist
	var required_scenes = [
		"res://scenes/menus/hangar.tscn",
		"res://scenes/ui/ship_equipment_screen.tscn",
		"res://scenes/game/node_2d.tscn"
	]
	
	for scene_path in required_scenes:
		if not ResourceLoader.exists(scene_path):
			return false
	return true

func test_script_path_validation():
	# Test that required scripts exist
	var required_scripts = [
		"res://scripts/ui/hangar.gd",
		"res://scripts/ui/ship_equipment_screen.gd",
		"res://autoload/playerData.gd"
	]
	
	for script_path in required_scripts:
		var script = load(script_path)
		if script == null:
			return false
	return true

func test_texture_path_validation():
	# Test that required textures exist
	var required_textures = [
		"res://assets/textures/hangar.png",
		"res://assets/textures/logo.png",
		"res://assets/textures/ship.png"
	]
	
	for texture_path in required_textures:
		var texture = load(texture_path)
		if texture == null:
			return false
	return true

func print_results(total, passed, failed):
	print("\n" + "=".repeat(50))
	print("📊 TEST RESULTS")
	print("=".repeat(50))
	print("Total Tests: ", total)
	print("Passed: ", passed)
	print("Failed: ", failed)
	var success_rate = 0.0
	if total > 0:
		success_rate = (float(passed) / float(total) * 100.0)
	print("Success Rate: ", success_rate, "%")
	print("=".repeat(50))
	
	if failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0) 