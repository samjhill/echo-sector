extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var speed: float = 300.0
@export var fire_interval: float = 0.5
@export var move_speed := 200.0
@export var rotation_speed := 5.0
@export var orbit_radius := 180.0
@export var orbit_speed := 1.0  # radians per second
@export var max_health := 5
@export var engine_component: EngineComponent
@export var weapon_components: Array[ShipComponent]


@onready var trajectory_line = $TrajectoryLine
@onready var camera = $Camera2D
@onready var health_bar = get_tree().root.get_node("Game/UI/HealthBar")

var weapon_cooldowns := []
var current_health := max_health
var target_position: Vector2
var moving_to_target := false
var orbiting := false
var orbit_angle := 0.0
var current_target: Node2D = null
var fire_timer: float = 0.0

func _ready():
	set_process_input(true)
	add_to_group("players")
	current_health = max_health
	target_position = global_position
	update_health_ui()
	
	# Engine
	#match player_data.equipped_engine:
		#"basic_engine":
			#engine_component = EngineComponent.new()
		#_:
			#engine_component = null

	# Weapons
	weapon_components.clear()
	for weapon in PlayerData.get_equipped_weapons():
		var weapon_name = weapon["name"]
		match weapon_name:
			"Pulse Laser Mk I":
				weapon_components.append(LaserWeapon.new())
			_:  # Unknown or unassigned
				print("Unknown weapon:", weapon_name)

	# Set up cooldowns for equipped weapons
	weapon_cooldowns.resize(weapon_components.size())
	for i in weapon_cooldowns.size():
		weapon_cooldowns[i] = 0.0


func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		_set_target(event.position)
	elif event is InputEventMouseButton and event.pressed:
		_set_target(event.position)

func take_damage(amount: int):
	current_health -= amount
	update_health_ui()
	if current_health <= 0:
		die()
		
func update_health_ui():
	if health_bar and health_bar.has_method("set_value"):
		health_bar.set_value(current_health)
		var label = health_bar.get_node("Label")
		label.text = "%d / %d" % [current_health, max_health]

func die():
	print("Player has died. Game Over.")
	var game_over_screen = preload("res://game_over_screen.tscn").instantiate()
	get_tree().root.add_child(game_over_screen)
	queue_free()
	
func _set_target(pos: Vector2):
	target_position = pos
	moving_to_target = true

	if current_target:
		# If we have a valid enemy target, orbit it
		orbiting = true
		orbit_angle = (global_position - current_target.global_position).angle()
	else:
		# Otherwise just move normally
		orbiting = false

func _physics_process(delta):
	if orbiting and current_target and is_instance_valid(current_target):
		camera.enabled = false  # Freeze camera
		orbit_angle += orbit_speed * delta
		var orbit_offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
		var desired_position = current_target.global_position + orbit_offset
		var direction = (desired_position - global_position)

		if direction.length() > 1.0:
			direction = direction.normalized()
			rotation = lerp_angle(rotation, direction.angle(), rotation_speed * delta)
			velocity = direction * move_speed
		else:
			velocity = Vector2.ZERO

	elif moving_to_target:
		var direction = target_position - global_position
		var distance = direction.length()

		if distance > 5.0:
			direction = direction.normalized()
			rotation = lerp_angle(rotation, direction.angle(), rotation_speed * delta)
			velocity = direction * move_speed
		else:
			moving_to_target = false
			velocity = Vector2.ZERO
	else:
		camera.enabled = true  # Unfreeze camera
		var input_vector = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized()

		velocity = input_vector * move_speed
		if input_vector == Vector2.ZERO:
			velocity = Vector2.ZERO

	move_and_slide()

func _process(delta):
	# Only draw the line if the target position is different from the current position
	if global_position.distance_to(target_position) > 5:
		trajectory_line.points = [
			Vector2.ZERO,
			to_local(target_position)
		]
		trajectory_line.visible = true
	else:
		trajectory_line.visible = false
		
	if current_target and is_instance_valid(current_target):
		fire_timer += delta
		if fire_timer >= fire_interval:
			fire_timer = 0.0
			#shoot_at_target(current_target)
		
		
		for i in weapon_components.size():
			var weapon = weapon_components[i]
			if weapon is LaserWeapon and current_target:
				weapon_cooldowns[i] += delta
				if weapon_cooldowns[i] >= weapon.cooldown:
					weapon_cooldowns[i] = 0.0
					shoot_laser(weapon, current_target)
	else:
		current_target = null

func shoot_laser(weapon: LaserWeapon, target: Node2D):
	var laser = preload("res://laser_projectile.tscn").instantiate()
	
	var direction = (target.global_position - global_position).normalized()
	laser.global_position = global_position
	laser.direction = direction
	laser.rotation = direction.angle()
	
	laser.damage = weapon.damage
	get_tree().current_scene.add_child(laser)


func shoot_at_target(target: Node2D):
	if not projectile_scene:
		print("No projectile scene assigned")
		return

	var bullet = projectile_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (target.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func lock_on_target(target: Node2D):
	print("Locking on target:", target.name)
	if current_target == target:
		# Already locked on, don't toggle off on second tap
		print("Already locked on target:", target.name)
		return

	if current_target and current_target.has_method("set_locked"):
		current_target.set_locked(false)

	if current_target == target:
		current_target = null  # Unlock if tapped again
		orbiting = false
	else:
		current_target = target
		fire_timer = 0.0  # Reset cooldown
		if current_target.has_method("set_locked"):
			current_target.set_locked(true)
			print("locked onto:", target.name)
		_set_target(target.global_position)
