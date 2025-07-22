extends Node2D
@export var enemy_scene: PackedScene

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
		2:
			enemy.speed = 100
			enemy.max_health = 3
			enemy.color = Color.RED # Balanced

	# Spawn enemy at screen edge
	var screen_size = get_viewport_rect().size
	enemy.global_position = Vector2(
		randf_range(0, screen_size.x),
		randf_range(0, screen_size.y)
	)
	add_child(enemy)
