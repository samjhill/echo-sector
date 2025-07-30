extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var speed: float = 300.0
@export var fire_interval: float = 0.5
@export var move_speed := 200.0
@export var rotation_speed := 5.0
@export var orbit_radius := 180.0
@export var orbit_speed := 1.0  # radians per second
@export var max_health := 5
@export var engine_component: Item
@export var weapon_components: Array[Item]


@onready var trajectory_line = $TrajectoryLine
@onready var camera = $Camera2D
@onready var sprite = $Sprite2D
@onready var health_bar = get_tree().root.get_node("Game/UI/HealthBar") if get_tree().root.has_node("Game/UI/HealthBar") else null

var weapon_cooldowns := []
var current_health := max_health
var target_position: Vector2
var moving_to_target := false
var orbiting := false
var orbit_angle := 0.0
var current_target: Node2D = null
var fire_timer: float = 0.0

# Hit effect variables
var is_flashing := false
var original_sprite_modulate: Color
var shake_timer := 0.0
var shake_intensity := 5.0
var original_camera_position: Vector2

# Trajectory line animation variables
var trajectory_animation_tween: Tween
var trajectory_alpha: float = 0.0

func _ready():
	set_process_input(true)
	add_to_group("players")
	current_health = max_health
	target_position = global_position
	update_health_ui()
	
	# Store original sprite and camera properties for hit effects
	original_sprite_modulate = sprite.modulate
	original_camera_position = camera.position
	
	# Set up trajectory line styling
	if trajectory_line:
		trajectory_line.width = 3.0
		trajectory_line.default_color = Color(0, 1, 0, 0.8)  # Green with transparency
		trajectory_line.antialiased = true
		trajectory_line.joint_mode = Line2D.LINE_JOINT_ROUND
		trajectory_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		trajectory_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	# Engine - handle array of engines
	if PlayerData.equipped_components.has("engine"):
		var engines = PlayerData.equipped_components["engine"]
		if engines.size() > 0 and engines[0] != null:
			engine_component = engines[0]  # Use first engine for now
		else:
			engine_component = null
	else:
		engine_component = null

	# Weapons - handle array of weapons
	weapon_components.clear()
	var equipped_weapons = PlayerData.get_equipped_weapons()
	print("Equipped weapons at start:", equipped_weapons.size())
	for weapon in equipped_weapons:
		if weapon != null:
			weapon_components.append(weapon)
			print("Added weapon:", weapon.name)
	
	print("Total weapon components:", weapon_components.size())
	
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
	
	# Trigger hit effects
	_trigger_hit_effects()
	
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	update_health_ui()
	print("Player healed! Health: " + str(current_health) + "/" + str(max_health))

func get_current_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health
		
func update_health_ui():
	if health_bar and health_bar.has_method("set_value"):
		health_bar.set_value(current_health)
		var label = health_bar.get_node("Label")
		if label:
			label.text = "%d / %d" % [current_health, max_health]
	else:
		print("Warning: Health bar not found or invalid")

func die():
	print("Player has died. Game Over.")
	var game_over_screen = preload("res://scenes/ui/game_over_screen.tscn").instantiate()
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
	# Update hit effects
	_update_hit_effects(delta)
	
	# Update trajectory line with improved visuals
	_update_trajectory_line()
		
	if current_target and is_instance_valid(current_target):
		fire_timer += delta
		if fire_timer >= fire_interval:
			fire_timer = 0.0
			#shoot_at_target(current_target)
		
		
		for i in range(weapon_components.size()):
			var weapon = weapon_components[i]
			if weapon != null and current_target:
				print("Processing weapon", i, ":", weapon.name, "type:", typeof(weapon), "class:", weapon.get_class())
				if weapon is LaserWeapon:
					print("Weapon is LaserWeapon, checking cooldown... Current cooldown:", weapon_cooldowns[i], "Required:", weapon.cooldown)
					weapon_cooldowns[i] += delta
					if weapon_cooldowns[i] >= weapon.cooldown:
						weapon_cooldowns[i] = 0.0
						print("Firing laser at target:", current_target)
						shoot_laser(weapon, current_target)
				elif weapon is RailgunWeapon:
					print("Weapon is RailgunWeapon, checking cooldown... Current cooldown:", weapon_cooldowns[i], "Required:", weapon.cooldown)
					weapon_cooldowns[i] += delta
					if weapon_cooldowns[i] >= weapon.cooldown:
						weapon_cooldowns[i] = 0.0
						print("Firing railgun at target:", current_target)
						shoot_railgun(weapon, current_target)
				else:
					print("Weapon is not recognized type:", typeof(weapon), "class:", weapon.get_class())
			elif weapon == null:
				print("Weapon", i, "is null")
			elif current_target == null:
				print("No current target")
	else:
		current_target = null

func _update_trajectory_line():
	if not trajectory_line:
		return
		
	var distance = global_position.distance_to(target_position)
	
	if distance > 5:
		# Show trajectory line with animation
		trajectory_line.points = [
			Vector2.ZERO,
			to_local(target_position)
		]
		
		# Animate the line appearance
		if not trajectory_line.visible:
			trajectory_line.visible = true
			_animate_trajectory_line_in()
		
		# Update line color based on target type
		if current_target:
			# Red for locked targets
			trajectory_line.default_color = Color(1, 0.3, 0.3, 0.9)
		else:
			# Green for movement targets
			trajectory_line.default_color = Color(0, 1, 0, 0.8)
	else:
		# Hide trajectory line with animation
		if trajectory_line.visible:
			_animate_trajectory_line_out()

func _animate_trajectory_line_in():
	if not trajectory_line:
		return
		
	# Stop any existing animation
	if trajectory_animation_tween:
		trajectory_animation_tween.kill()
	
	trajectory_animation_tween = create_tween()
	trajectory_animation_tween.tween_property(trajectory_line, "modulate:a", 0.0, 0.0)
	trajectory_animation_tween.tween_property(trajectory_line, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT)

func _animate_trajectory_line_out():
	if not trajectory_line:
		return
		
	# Stop any existing animation
	if trajectory_animation_tween:
		trajectory_animation_tween.kill()
	
	trajectory_animation_tween = create_tween()
	trajectory_animation_tween.tween_property(trajectory_line, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)
	trajectory_animation_tween.tween_callback(func(): trajectory_line.visible = false)

func _update_hit_effects(delta):
	# Update flash effect
	if is_flashing:
		var flash_progress = (Time.get_time_dict_from_system()["second"] * 20) % 2
		if flash_progress < 1:
			sprite.modulate = Color.RED
		else:
			sprite.modulate = Color.WHITE
	
	# Update camera shake
	if shake_timer > 0:
		shake_timer -= delta
		if shake_timer <= 0:
			camera.position = original_camera_position
		else:
			var shake_offset = Vector2(
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity)
			)
			camera.position = original_camera_position + shake_offset

func _trigger_hit_effects():
	# Flash effect
	is_flashing = true
	await get_tree().create_timer(0.3).timeout
	is_flashing = false
	sprite.modulate = original_sprite_modulate
	
	# Camera shake
	shake_timer = 0.2
	shake_intensity = 3.0

func shoot_laser(weapon: LaserWeapon, target: Node2D):
	print("shoot_laser called with weapon:", weapon.name, "target:", target.name)
	var laser = preload("res://scenes/game/laser_projectile.tscn").instantiate()
	
	var direction = (target.global_position - global_position).normalized()
	laser.global_position = global_position
	laser.direction = direction
	laser.rotation = direction.angle()
	
	laser.damage = weapon.damage
	print("Created laser with damage:", weapon.damage, "direction:", direction)
	get_tree().current_scene.add_child(laser)
	print("Added laser to scene")


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
	
	# Notify tutorial system about enemy tap
	var game_tutorial = get_tree().get_first_node_in_group("game_tutorial")
	if game_tutorial and game_tutorial.has_method("on_enemy_tapped"):
		game_tutorial.on_enemy_tapped(target)
	
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
		print("New current_target set:", current_target)
		fire_timer = 0.0  # Reset cooldown
		if current_target.has_method("set_locked"):
			current_target.set_locked(true)
			print("locked onto:", target.name)
		_set_target(target.global_position)

func shoot_railgun(weapon: RailgunWeapon, target: Node2D):
	print("shoot_railgun called with weapon:", weapon.name, "target:", target.name)
	var projectile = preload("res://scenes/game/projectile.tscn").instantiate()
	
	var direction = (target.global_position - global_position).normalized()
	projectile.global_position = global_position
	projectile.direction = direction
	projectile.rotation = direction.angle()
	
	projectile.damage = weapon.damage
	projectile.speed = weapon.projectile_speed
	print("Created railgun projectile with damage:", weapon.damage, "speed:", weapon.projectile_speed, "direction:", direction)
	get_tree().current_scene.add_child(projectile)
	print("Added railgun projectile to scene")
