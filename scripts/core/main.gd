extends Node2D
@export var enemy_scene: PackedScene

# Run statistics
var enemies_killed := 0
var credits_earned_this_run := 0
var scrap_earned_this_run := 0

func _ready():
	spawn_enemy_timer()

func spawn_enemy_timer():
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.timeout.connect(_on_spawn_enemy)
	add_child(timer)
	timer.start()

func _on_spawn_enemy():
	var enemy = enemy_scene.instantiate()

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
	
	add_child(enemy)

func _on_enemy_killed():
	enemies_killed += 1
	credits_earned_this_run += 5  # Base credit reward per enemy
	scrap_earned_this_run += 3    # Base scrap reward per enemy
	print("Run stats - Enemies killed:", enemies_killed, " Credits:", credits_earned_this_run, " Scrap:", scrap_earned_this_run)

func get_run_statistics() -> Dictionary:
	return {
		"enemies_killed": enemies_killed,
		"credits_earned": credits_earned_this_run,
		"scrap_earned": scrap_earned_this_run
	}
