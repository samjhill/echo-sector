extends SceneTree

func _init():
	print("🧪 Testing Collision Layer Setup...")
	
	# Test projectile scene collision setup
	test_projectile_collision_setup()
	
	# Test enemy scene collision setup  
	test_enemy_collision_setup()
	
	# Test laser projectile collision setup
	test_laser_projectile_collision_setup()
	
	# Test enemy projectile collision setup
	test_enemy_projectile_collision_setup()
	
	print("✅ All collision layer tests completed!")
	quit()

func test_projectile_collision_setup():
	var projectile_scene = load("res://scenes/game/projectile.tscn")
	if not projectile_scene:
		print("❌ Failed to load projectile scene")
		return
		
	var projectile = projectile_scene.instantiate()
	
	# Check collision layer and mask
	if projectile.collision_layer != 4:
		print("❌ Projectile collision_layer should be 4, got: " + str(projectile.collision_layer))
	else:
		print("✅ Projectile collision_layer is correct (4)")
		
	if projectile.collision_mask != 8:
		print("❌ Projectile collision_mask should be 8, got: " + str(projectile.collision_mask))
	else:
		print("✅ Projectile collision_mask is correct (8)")
	
	projectile.queue_free()

func test_enemy_collision_setup():
	var enemy_scene = load("res://scenes/game/enemy.tscn")
	if not enemy_scene:
		print("❌ Failed to load enemy scene")
		return
		
	var enemy = enemy_scene.instantiate()
	
	# Check collision layer and mask
	if enemy.collision_layer != 8:
		print("❌ Enemy collision_layer should be 8, got: " + str(enemy.collision_layer))
	else:
		print("✅ Enemy collision_layer is correct (8)")
		
	if enemy.collision_mask != 4:
		print("❌ Enemy collision_mask should be 4, got: " + str(enemy.collision_mask))
	else:
		print("✅ Enemy collision_mask is correct (4)")
	
	enemy.queue_free()

func test_laser_projectile_collision_setup():
	var laser_scene = load("res://scenes/game/laser_projectile.tscn")
	if not laser_scene:
		print("❌ Failed to load laser projectile scene")
		return
		
	var laser = laser_scene.instantiate()
	
	# Check collision layer and mask
	if laser.collision_layer != 4:
		print("❌ Laser projectile collision_layer should be 4, got: " + str(laser.collision_layer))
	else:
		print("✅ Laser projectile collision_layer is correct (4)")
		
	if laser.collision_mask != 8:
		print("❌ Laser projectile collision_mask should be 8, got: " + str(laser.collision_mask))
	else:
		print("✅ Laser projectile collision_mask is correct (8)")
	
	laser.queue_free()

func test_enemy_projectile_collision_setup():
	var enemy_projectile_scene = load("res://scenes/game/enemy_projectile.tscn")
	if not enemy_projectile_scene:
		print("❌ Failed to load enemy projectile scene")
		return
		
	var enemy_projectile = enemy_projectile_scene.instantiate()
	
	# Check collision layer and mask
	if enemy_projectile.collision_layer != 16:
		print("❌ Enemy projectile collision_layer should be 16, got: " + str(enemy_projectile.collision_layer))
	else:
		print("✅ Enemy projectile collision_layer is correct (16)")
		
	if enemy_projectile.collision_mask != 2:
		print("❌ Enemy projectile collision_mask should be 2, got: " + str(enemy_projectile.collision_mask))
	else:
		print("✅ Enemy projectile collision_mask is correct (2)")
	
	enemy_projectile.queue_free()
