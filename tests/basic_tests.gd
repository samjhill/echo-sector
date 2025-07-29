extends MainLoop

# Basic tests that don't rely on autoloads
# These tests verify that all required files exist and can be loaded

func _initialize():
	print("🧪 Starting Echo Sector Basic Tests...")
	run_basic_tests()
	return true

func _process(_delta):
	# Stop processing after tests are done
	return false

func run_basic_tests():
	var total_tests = 0
	var passed_tests = 0
	var failed_tests = 0
	
	print("\n📋 Running File Existence Tests...")
	var file_tests = run_file_existence_tests()
	total_tests += file_tests.total
	passed_tests += file_tests.passed
	failed_tests += file_tests.failed
	
	print("\n📋 Running Resource Loading Tests...")
	var resource_tests = run_resource_loading_tests()
	total_tests += resource_tests.total
	passed_tests += resource_tests.passed
	failed_tests += resource_tests.failed
	
	print("\n📋 Running Script Loading Tests...")
	var script_tests = run_script_loading_tests()
	total_tests += script_tests.total
	passed_tests += script_tests.passed
	failed_tests += script_tests.failed
	
	print_results(total_tests, passed_tests, failed_tests)

func run_file_existence_tests():
	var total = 0
	var passed = 0
	var failed = 0
	
	# Test 1: Check if project.godot exists
	total += 1
	if FileAccess.file_exists("res://project.godot"):
		passed += 1
		print("  ✅ project.godot exists")
	else:
		failed += 1
		print("  ❌ project.godot missing")
	
	# Test 2: Check if main scene exists
	total += 1
	if ResourceLoader.exists("res://scenes/menus/hangar.tscn"):
		passed += 1
		print("  ✅ hangar.tscn exists")
	else:
		failed += 1
		print("  ❌ hangar.tscn missing")
	
	# Test 3: Check if game scene exists
	total += 1
	if ResourceLoader.exists("res://scenes/game/node_2d.tscn"):
		passed += 1
		print("  ✅ node_2d.tscn exists")
	else:
		failed += 1
		print("  ❌ node_2d.tscn missing")
	
	return {"total": total, "passed": passed, "failed": failed}

func run_resource_loading_tests():
	var total = 0
	var passed = 0
	var failed = 0
	
	# Test 1: Load item script
	total += 1
	var item_script = load("res://scripts/core/item.gd")
	if item_script != null:
		passed += 1
		print("  ✅ item.gd loads successfully")
	else:
		failed += 1
		print("  ❌ item.gd failed to load")
	
	# Test 2: Load engine component script
	total += 1
	var engine_script = load("res://components/engine_component.gd")
	if engine_script != null:
		passed += 1
		print("  ✅ engine_component.gd loads successfully")
	else:
		failed += 1
		print("  ❌ engine_component.gd failed to load")
	
	# Test 3: Load basic engine resource
	total += 1
	var engine_resource = load("res://components/basic_engine.tres")
	if engine_resource != null:
		passed += 1
		print("  ✅ basic_engine.tres loads successfully")
	else:
		failed += 1
		print("  ❌ basic_engine.tres failed to load")
	
	return {"total": total, "passed": passed, "failed": failed}

func run_script_loading_tests():
	var total = 0
	var passed = 0
	var failed = 0
	
	# Test 1: Load hangar script
	total += 1
	var hangar_script = load("res://scripts/ui/hangar.gd")
	if hangar_script != null:
		passed += 1
		print("  ✅ hangar.gd loads successfully")
	else:
		failed += 1
		print("  ❌ hangar.gd failed to load")
	
	# Test 2: Load equipment screen script
	total += 1
	var equipment_script = load("res://scripts/ui/ship_equipment_screen.gd")
	if equipment_script != null:
		passed += 1
		print("  ✅ ship_equipment_screen.gd loads successfully")
	else:
		failed += 1
		print("  ❌ ship_equipment_screen.gd failed to load")
	
	# Test 3: Load player data script
	total += 1
	var player_data_script = load("res://autoload/playerData.gd")
	if player_data_script != null:
		passed += 1
		print("  ✅ playerData.gd loads successfully")
	else:
		failed += 1
		print("  ❌ playerData.gd failed to load")
	
	return {"total": total, "passed": passed, "failed": failed}

func print_results(total, passed, failed):
	print("\n" + "=".repeat(50))
	print("📊 BASIC TEST RESULTS")
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
		print("❌ Some tests failed! Check the file structure and paths.")
		print("🔧 Please check the missing files above and ensure they exist.")
	else:
		print("✅ All basic tests passed! File structure is correct.")
		print("🎉 Your Echo Sector project structure is correct!")
	
	# Let the script finish naturally
	print("🏁 Test execution completed.") 