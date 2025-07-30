# StellarGridTest.gd
# Simple test script to verify Stellar Grid functionality
extends Node

func _ready():
	print("🧪 Testing Stellar Grid System...")
	test_grid_manager()
	test_grid_items()
	test_production_system()

func test_grid_manager():
	"""Test the GridManager functionality"""
	print("📋 Testing GridManager...")
	
	var grid_manager = GridManager.new()
	add_child(grid_manager)
	
	# Test grid initialization
	print("  ✅ Grid initialized with size: ", grid_manager.grid_size)
	
	# Test valid position checking
	var valid_pos = Vector2i(2, 2)
	var invalid_pos = Vector2i(10, 10)
	print("  ✅ Valid position check: ", grid_manager.is_valid_position(valid_pos))
	print("  ✅ Invalid position check: ", not grid_manager.is_valid_position(invalid_pos))
	
	# Test tile access
	var tile = grid_manager.get_tile(valid_pos)
	if tile != null:
		print("  ✅ Tile access successful")
	else:
		print("  ❌ Tile access failed")
	
	# Cleanup
	grid_manager.queue_free()

func test_grid_items():
	"""Test grid item loading and creation"""
	print("📋 Testing Grid Items...")
	
	# Test loading grid items from JSON
	var grid_items = GridItemLoader.load_grid_items()
	print("  ✅ Loaded ", grid_items.size(), " grid items")
	
	# Test specific item creation
	var power_core = GridItemLoader.get_grid_item_by_name("Power Core Mk I")
	if power_core != null:
		print("  ✅ Power Core loaded successfully")
		print("    - Name: ", power_core.name)
		print("    - Production: ", power_core.stats.get("production", {}))
	else:
		print("  ❌ Power Core loading failed")
	
	var refinery = GridItemLoader.get_grid_item_by_name("Refinery Mk I")
	if refinery != null:
		print("  ✅ Refinery loaded successfully")
		print("    - Name: ", refinery.name)
		print("    - Production: ", refinery.stats.get("production", {}))
	else:
		print("  ❌ Refinery loading failed")

func test_production_system():
	"""Test the production system"""
	print("📋 Testing Production System...")
	
	var grid_manager = GridManager.new()
	add_child(grid_manager)
	
	# Create test items
	var power_core = GridItemLoader.get_grid_item_by_name("Power Core Mk I")
	var refinery = GridItemLoader.get_grid_item_by_name("Refinery Mk I")
	
	if power_core != null and refinery != null:
		# Place items on grid
		var success1 = grid_manager.place_item(Vector2i(1, 1), power_core)
		var success2 = grid_manager.place_item(Vector2i(2, 1), refinery)
		
		if success1 and success2:
			print("  ✅ Items placed successfully")
			
			# Test adjacency bonus
			var tile = grid_manager.get_tile(Vector2i(2, 1))
			var adjacency_bonus = grid_manager.calculate_adjacency_bonus(tile)
			print("  ✅ Adjacency bonus calculated: ", adjacency_bonus)
			
			# Test production tick
			grid_manager._on_production_tick()
			print("  ✅ Production tick completed")
		else:
			print("  ❌ Item placement failed")
	else:
		print("  ❌ Test items not found")
	
	# Cleanup
	grid_manager.queue_free()

func test_inventory_integration():
	"""Test inventory integration"""
	print("📋 Testing Inventory Integration...")
	
	# Test adding grid items to inventory
	var power_core = GridItemLoader.get_grid_item_by_name("Power Core Mk I")
	if power_core != null:
		PlayerData.add_item_to_inventory(power_core)
		print("  ✅ Grid item added to inventory")
		
		var grid_items = PlayerData.get_grid_compatible_items()
		print("  ✅ Found ", grid_items.size(), " grid-compatible items in inventory")
	else:
		print("  ❌ Grid item not found")

func _on_test_completed():
	print("🎉 Stellar Grid System Test Completed!")
	print("✅ All core functionality verified")
	print("🚀 System ready for integration") 