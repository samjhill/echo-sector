extends BaseTestSuite
class_name ResourceLoadingTestSuite

# Test loading of different resource types
func test_load_item_class():
	var item_resource = load("res://scripts/core/item.gd")
	assert_not_null(item_resource, "Item class should load successfully")
	
	var item = item_resource.new()
	assert_not_null(item, "Item should instantiate successfully")
	assert_true(item is Item, "Item should be of type Item")

func test_load_laser_weapon():
	var weapon_resource = load("res://components/laserWeapon.gd")
	assert_not_null(weapon_resource, "LaserWeapon class should load successfully")
	
	var weapon = weapon_resource.new()
	assert_not_null(weapon, "LaserWeapon should instantiate successfully")
	assert_true(weapon is LaserWeapon, "Weapon should be of type LaserWeapon")
	assert_true(weapon is Item, "LaserWeapon should extend Item")

func test_load_railgun_weapon():
	var weapon_resource = load("res://components/railgunWeapon.gd")
	assert_not_null(weapon_resource, "RailgunWeapon class should load successfully")
	
	var weapon = weapon_resource.new()
	assert_not_null(weapon, "RailgunWeapon should instantiate successfully")
	assert_true(weapon is RailgunWeapon, "Weapon should be of type RailgunWeapon")
	assert_true(weapon is Item, "RailgunWeapon should extend Item")

func test_load_engine_component():
	var engine_resource = load("res://components/engine_component.gd")
	assert_not_null(engine_resource, "EngineComponent class should load successfully")
	
	var engine = engine_resource.new()
	assert_not_null(engine, "EngineComponent should instantiate successfully")
	assert_true(engine is EngineComponent, "Engine should be of type EngineComponent")
	assert_true(engine is Item, "EngineComponent should extend Item")

# Test loading of .tres resource files
func test_load_basic_engine_tres():
	var engine_resource = load("res://components/basic_engine.tres")
	assert_not_null(engine_resource, "Basic engine .tres should load successfully")
	assert_true(engine_resource is EngineComponent, "Loaded resource should be EngineComponent")
	assert_true(engine_resource is Resource, "Loaded resource should be a Resource instance")
	assert_false(engine_resource is Script, "Loaded resource should not be a Script")

func test_load_afterburner_engine_tres():
	var engine_resource = load("res://components/afterburner_engine.tres")
	assert_not_null(engine_resource, "Afterburner engine .tres should load successfully")
	assert_true(engine_resource is EngineComponent, "Loaded resource should be EngineComponent")
	assert_true(engine_resource is Resource, "Loaded resource should be a Resource instance")
	assert_false(engine_resource is Script, "Loaded resource should not be a Script")

# Test resource properties
func test_basic_engine_properties():
	var engine = load("res://components/basic_engine.tres")
	assert_equal("Basic Engine", engine.name, "Basic engine should have correct name")
	assert_equal("Reliable but slow thruster to get you around.", engine.description, "Basic engine should have correct description")
	assert_equal("engine", engine.slot_type, "Basic engine should have correct slot type")
	assert_equal(100.0, engine.move_speed_bonus, "Basic engine should have correct move speed bonus")
	assert_equal(2.0, engine.rotation_speed_bonus, "Basic engine should have correct rotation speed bonus")

func test_afterburner_engine_properties():
	var engine = load("res://components/afterburner_engine.tres")
	assert_equal("Afterburner", engine.name, "Afterburner should have correct name")
	assert_equal("Short bursts of speed.", engine.description, "Afterburner should have correct description")
	assert_equal("engine", engine.slot_type, "Afterburner should have correct slot type")
	assert_equal(200.0, engine.move_speed_bonus, "Afterburner should have correct move speed bonus")
	assert_equal(3.0, engine.rotation_speed_bonus, "Afterburner should have correct rotation speed bonus")

func test_laser_weapon_properties():
	var weapon_class = load("res://components/laserWeapon.gd")
	var weapon = weapon_class.new()
	weapon.name = "Test Laser"
	weapon.description = "Test laser weapon"
	weapon.slot_type = "weapon"
	
	assert_equal(10, weapon.damage, "Laser weapon should have default damage")
	assert_equal(2.5, weapon.cooldown, "Laser weapon should have default cooldown")
	assert_true(weapon is Item, "Laser weapon should extend Item")

func test_railgun_weapon_properties():
	var weapon_class = load("res://components/railgunWeapon.gd")
	var weapon = weapon_class.new()
	weapon.name = "Test Railgun"
	weapon.description = "Test railgun weapon"
	weapon.slot_type = "weapon"
	
	assert_equal(15, weapon.damage, "Railgun weapon should have default damage")
	assert_equal(1.5, weapon.cooldown, "Railgun weapon should have default cooldown")
	assert_equal(600.0, weapon.projectile_speed, "Railgun weapon should have default projectile speed")
	assert_true(weapon is Item, "Railgun weapon should extend Item")

# Test resource type detection
func test_resource_type_detection():
	# Test .gd files (Scripts)
	var item_script = load("res://scripts/core/item.gd")
	assert_true(item_script is Script, "Item script should be a Script")
	assert_false(item_script is Resource, "Item script should not be a Resource instance")
	
	# Test .tres files (Resources)
	var engine_resource = load("res://components/basic_engine.tres")
	assert_true(engine_resource is Resource, "Engine resource should be a Resource")
	assert_false(engine_resource is Script, "Engine resource should not be a Script")

# Test error handling for missing resources
func test_missing_resource_handling():
	# Test loading a non-existent resource
	var missing_resource = load("res://non_existent_file.gd")
	assert_null(missing_resource, "Missing resource should return null")
	
	var missing_tres = load("res://non_existent_file.tres")
	assert_null(missing_tres, "Missing .tres file should return null")

# Test resource instantiation patterns
func test_script_instantiation():
	var item_script = load("res://scripts/core/item.gd")
	var item = item_script.new()
	assert_not_null(item, "Script should instantiate successfully")
	assert_true(item is Item, "Instantiated item should be of type Item")

func test_resource_usage():
	var engine_resource = load("res://components/basic_engine.tres")
	# Resource instances should be used directly, not instantiated
	assert_not_null(engine_resource, "Resource should be usable directly")
	assert_true(engine_resource is EngineComponent, "Resource should be of correct type")

# Test resource path validation
func test_valid_resource_paths():
	var valid_paths = [
		"res://scripts/core/item.gd",
		"res://components/laserWeapon.gd",
		"res://components/railgunWeapon.gd",
		"res://components/engine_component.gd",
		"res://components/basic_engine.tres",
		"res://components/afterburner_engine.tres"
	]
	
	for path in valid_paths:
		var resource = load(path)
		assert_not_null(resource, "Resource should load: " + path)

# Test resource inheritance hierarchy
func test_inheritance_hierarchy():
	# Test that weapons inherit from Item
	var laser_class = load("res://components/laserWeapon.gd")
	var laser = laser_class.new()
	assert_true(laser is Item, "LaserWeapon should inherit from Item")
	
	var railgun_class = load("res://components/railgunWeapon.gd")
	var railgun = railgun_class.new()
	assert_true(railgun is Item, "RailgunWeapon should inherit from Item")
	
	# Test that engines inherit from Item
	var engine_class = load("res://components/engine_component.gd")
	var engine = engine_class.new()
	assert_true(engine is Item, "EngineComponent should inherit from Item")
	
	# Test that .tres resources are also Items
	var basic_engine = load("res://components/basic_engine.tres")
	assert_true(basic_engine is Item, "Basic engine resource should be an Item")
	
	var afterburner = load("res://components/afterburner_engine.tres")
	assert_true(afterburner is Item, "Afterburner resource should be an Item")

# Test resource serialization compatibility
func test_resource_serialization():
	# Test that resources can be properly serialized/deserialized
	var engine = load("res://components/basic_engine.tres")
	
	# Create a copy of the engine data
	var engine_data = {
		"name": engine.name,
		"description": engine.description,
		"slot_type": engine.slot_type,
		"move_speed_bonus": engine.move_speed_bonus,
		"rotation_speed_bonus": engine.rotation_speed_bonus
	}
	
	# Verify the data is correct
	assert_equal("Basic Engine", engine_data.name, "Serialized name should be correct")
	assert_equal("engine", engine_data.slot_type, "Serialized slot type should be correct")
	assert_equal(100.0, engine_data.move_speed_bonus, "Serialized move speed should be correct") 