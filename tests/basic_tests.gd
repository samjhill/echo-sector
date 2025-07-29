extends MainLoop

func _initialize():
	print("🧪 Starting Echo Sector Basic Tests...")
	
	# Test file existence
	print("📋 Running File Existence Tests...")
	_test_file_exists("project.godot")
	_test_file_exists("scenes/menus/hangar.tscn")
	_test_file_exists("scenes/game/node_2d.tscn")
	
	# Test basic script loading (only scripts that don't depend on autoloads)
	print("📋 Running Basic Script Loading Tests...")
	_test_script_loads("scripts/core/item.gd")
	_test_script_loads("scripts/core/trajectory_line.gd")
	_test_script_loads("scripts/core/texture_rect.gd")
	
	# Test weapon scripts (skip if they don't exist)
	print("📋 Running Weapon Script Tests...")
	_test_script_loads_optional("scripts/weapons/base_weapon.gd")
	_test_script_loads_optional("scripts/weapons/laser_weapon.gd")
	_test_script_loads_optional("scripts/weapons/railgun_weapon.gd")
	
	# Test scene loading
	print("📋 Running Scene Loading Tests...")
	_test_scene_loads("scenes/menus/hangar.tscn")
	_test_scene_loads("scenes/game/node_2d.tscn")
	_test_scene_loads("scenes/ui/ship_equipment_screen.tscn")
	
	# Test texture loading
	print("📋 Running Texture Loading Tests...")
	_test_texture_loads("assets/textures/ship.png")
	_test_texture_loads("assets/textures/logo.png")
	_test_texture_loads("assets/textures/hangar.png")
	_test_texture_loads("assets/textures/enemy_image.png")
	
	print("==================================================")
	print("📊 BASIC TEST RESULTS")
	print("==================================================")
	print("Total Tests: " + str(total_tests))
	print("Passed: " + str(passed_tests))
	print("Failed: " + str(failed_tests))
	print("Success Rate: " + str((float(passed_tests) / float(total_tests)) * 100) + "%")
	print("==================================================")
	
	if failed_tests > 0:
		print("❌ Some tests failed! Check the file structure and paths.")
		print("🔧 Please check the missing files above and ensure they exist.")
		return 1
	else:
		print("🎉 All tests passed!")
		return 0

var total_tests = 0
var passed_tests = 0
var failed_tests = 0

func _test_file_exists(path: String):
	total_tests += 1
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		print("  ✅ " + path + " exists")
		passed_tests += 1
		file.close()
	else:
		print("  ❌ " + path + " missing")
		failed_tests += 1

func _test_script_loads(path: String):
	total_tests += 1
	var script = load(path)
	if script:
		print("  ✅ " + path + " loads successfully")
		passed_tests += 1
	else:
		print("  ❌ " + path + " failed to load")
		failed_tests += 1

func _test_script_loads_optional(path: String):
	# Only test if file exists
	if FileAccess.file_exists(path):
		total_tests += 1
		var script = load(path)
		if script:
			print("  ✅ " + path + " loads successfully")
			passed_tests += 1
		else:
			print("  ❌ " + path + " failed to load")
			failed_tests += 1
	else:
		print("  ⚠️ " + path + " not found (skipping)")

func _test_resource_loads(path: String):
	total_tests += 1
	var resource = load(path)
	if resource:
		print("  ✅ " + path + " loads successfully")
		passed_tests += 1
	else:
		print("  ❌ " + path + " failed to load")
		failed_tests += 1

func _test_scene_loads(path: String):
	total_tests += 1
	var scene = load(path)
	if scene:
		print("  ✅ " + path + " loads successfully")
		passed_tests += 1
	else:
		print("  ❌ " + path + " failed to load")
		failed_tests += 1

func _test_texture_loads(path: String):
	total_tests += 1
	var texture = load(path)
	if texture:
		print("  ✅ " + path + " loads successfully")
		passed_tests += 1
	else:
		print("  ❌ " + path + " failed to load")
		failed_tests += 1 