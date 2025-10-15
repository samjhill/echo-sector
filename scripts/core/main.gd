extends Node2D
@export var enemy_scene: PackedScene

# Run statistics
var enemies_killed := 0
var credits_earned_this_run := 0
var scrap_earned_this_run := 0

# Tutorial system
var game_tutorial: GameTutorial = null

# Error display system
var error_display: ErrorDisplay = null

# Fallback timer for tutorial completion
var fallback_timer: Timer = null

func _ready():
	# Setup error display
	setup_error_display()
	
	# Setup tutorial system
	setup_tutorial()
	
	# Only start enemy spawning if tutorial is not active
	if not game_tutorial or not game_tutorial.should_show_tutorial():
		Logger.info("Tutorial not needed, starting enemy spawning immediately", "Main")
		spawn_enemy_timer()
	else:
		# Wait for tutorial to complete before spawning enemies
		Logger.info("Tutorial active, connecting completion signal", "Main")
		game_tutorial.tutorial_completed.connect(_on_tutorial_completed_and_start_spawning)
		Logger.info("Signal connection status: %s" % game_tutorial.tutorial_completed.is_connected(_on_tutorial_completed_and_start_spawning), "Main")
		
		# Add a fallback timer to check if spawning should have started
		fallback_timer = Timer.new()
		fallback_timer.wait_time = 10.0  # 10 seconds
		fallback_timer.timeout.connect(_check_spawning_status)
		add_child(fallback_timer)
		fallback_timer.start()

func setup_tutorial():
	"""Setup the game tutorial system"""
	game_tutorial = GameTutorial.new()
	add_child(game_tutorial)
	
	# Start tutorial if needed
	if game_tutorial.should_show_tutorial():
		game_tutorial.start_tutorial()
		Logger.info("Game tutorial setup complete", "Main")
	else:
		Logger.info("Game tutorial already completed", "Main")

func setup_error_display():
	"""Setup the error display system"""
	error_display = ErrorDisplay.new()
	add_child(error_display)

func _on_tutorial_completed_and_start_spawning():
	"""Handle tutorial completion and start enemy spawning"""
	Logger.info("Tutorial completed, starting enemy spawning", "Main")
	spawn_enemy_timer()
	
	# Clean up fallback timer since tutorial completed normally
	if fallback_timer:
		fallback_timer.queue_free()
		fallback_timer = null
	
	# Disconnect the signal to prevent multiple calls
	if game_tutorial and game_tutorial.tutorial_completed.is_connected(_on_tutorial_completed_and_start_spawning):
		game_tutorial.tutorial_completed.disconnect(_on_tutorial_completed_and_start_spawning)
		Logger.info("Disconnected tutorial completion signal", "Main")

func _input(event):
	"""Handle input for debugging"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			Logger.info("Manual enemy spawn triggered", "Main")
			spawn_enemy_timer()

func _check_spawning_status():
	"""Check if enemy spawning should have started but didn't"""
	Logger.info("Checking spawning status after 10 seconds", "Main")
	
	# Check if tutorial is still active
	if game_tutorial and game_tutorial.tutorial_active:
		Logger.info("Tutorial is still active, this might be the issue", "Main")
	else:
		Logger.info("Tutorial is not active, spawning should have started", "Main")
		# Force start spawning if it hasn't started
		spawn_enemy_timer()
	
	# Clean up the fallback timer
	if fallback_timer:
		fallback_timer.queue_free()
		fallback_timer = null

func spawn_enemy_timer():
	Logger.info("Creating enemy spawn timer", "Main")
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.timeout.connect(_on_spawn_enemy)
	add_child(timer)
	timer.start()
	Logger.info("Enemy spawn timer started", "Main")

func _on_spawn_enemy():
	Logger.info("Spawning enemy", "Main")
	var enemy = enemy_scene.instantiate()
	
	# Ensure enemy is visible
	enemy.visible = true
	Logger.info("Enemy visibility set to: %s" % enemy.visible, "Main")
	
	# Ensure enemy sprite is visible
	var enemy_sprite = enemy.get_node("Sprite2D")
	if enemy_sprite:
		enemy_sprite.visible = true
		Logger.info("Enemy sprite visibility set to: %s" % enemy_sprite.visible, "Main")

	# Randomize enemy type
	var roll = randi_range(0, 2)
	match roll:
		0:
			enemy.speed = 80
			enemy.max_health = 5
			enemy.color = Color.GREEN # Tank
		1:
			enemy.speed = 120
			enemy.max_health = 2
			enemy.color = Color.YELLOW # Fast
			enemy.fire_interval = 1
		2:
			enemy.speed = 100
			enemy.max_health = 3
			enemy.color = Color.RED # Balanced
			enemy.fire_interval = 3

	# Spawn enemy at screen edge
	var screen_size = get_viewport_rect().size
	enemy.global_position = Vector2(
		randf_range(0, screen_size.x),
		randf_range(0, screen_size.y)
	)
	
	# Connect to this enemy's death signal
	enemy.enemy_killed.connect(_on_enemy_killed)
	
	# If this is a tutorial enemy, also connect to tutorial system
	if game_tutorial and game_tutorial.tutorial_active:
		enemy.enemy_killed.connect(_on_tutorial_enemy_killed)
	
	add_child(enemy)
	
	# Check if this is the first enemy for tutorial
	if game_tutorial and game_tutorial.tutorial_active and game_tutorial.current_step == game_tutorial.TutorialStep.ENEMY_HIGHLIGHT:
		# Wait a moment for enemy to fully spawn, then highlight it
		await get_tree().create_timer(0.5).timeout
		game_tutorial.highlight_enemy(enemy)
		Logger.info("First enemy spawned and highlighted for tutorial", "Main")

func _on_enemy_killed():
	enemies_killed += 1
	credits_earned_this_run += 5  # Base credit reward per enemy
	scrap_earned_this_run += 3    # Base scrap reward per enemy
	print("Run stats - Enemies killed:", enemies_killed, " Credits:", credits_earned_this_run, " Scrap:", scrap_earned_this_run)
	
	# Notify tutorial system about enemy destruction
	if game_tutorial and game_tutorial.has_method("on_enemy_destroyed"):
		game_tutorial.on_enemy_destroyed(null)  # We don't have the enemy reference here

func _on_tutorial_enemy_killed():
	"""Handle tutorial enemy destruction"""
	Logger.info("Tutorial enemy killed", "Main")
	if game_tutorial and game_tutorial.has_method("on_enemy_destroyed"):
		game_tutorial.on_enemy_destroyed(null)

func get_run_statistics() -> Dictionary:
	return {
		"enemies_killed": enemies_killed,
		"credits_earned": credits_earned_this_run,
		"scrap_earned": scrap_earned_this_run
	}
