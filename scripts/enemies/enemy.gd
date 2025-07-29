extends CharacterBody2D

signal enemy_killed

@export var speed: float = 100.0
@export var max_health: int = 3
@export var color: Color = Color.RED
@onready var sprite := $Sprite2D
@export var damage_number_scene: PackedScene
@export var fire_interval := 5
@export var projectile_scene: PackedScene

var fire_timer := 0.0
var health: int
var lock_ring: Sprite2D
var lock_animation_tween: Tween

func _ready():
	health = max_health
	sprite.modulate = color
	add_to_group("enemies")
	
	# Get the lock ring reference
	lock_ring = $LockRing
	
	# Set up initial lock ring properties
	if lock_ring:
		lock_ring.modulate = Color(0, 1, 0, 0.8)  # Green with transparency
		lock_ring.scale = Vector2(0.2, 0.2)  # Start smaller
		lock_ring.rotation = 0

func set_locked(is_locked: bool):
	print("set_locked called on ", self.name, " — locked: ", is_locked)
	
	if not lock_ring:
		return
		
	if is_locked:
		# Show and animate the lock ring
		lock_ring.visible = true
		_animate_lock_ring_in()
	else:
		# Hide the lock ring
		_animate_lock_ring_out()

func _animate_lock_ring_in():
	if not lock_ring:
		return
		
	# Stop any existing animation
	if lock_animation_tween:
		lock_animation_tween.kill()
	
	lock_animation_tween = create_tween()
	lock_animation_tween.set_parallel(true)
	
	# Scale animation - grow from small to normal size
	lock_animation_tween.tween_property(lock_ring, "scale", Vector2(0.2, 0.2), 0.0)
	lock_animation_tween.tween_property(lock_ring, "scale", Vector2(0.25, 0.25), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Opacity animation - fade in
	lock_animation_tween.tween_property(lock_ring, "modulate:a", 0.0, 0.0)
	lock_animation_tween.tween_property(lock_ring, "modulate:a", 0.9, 0.3).set_ease(Tween.EASE_OUT)
	
	# Start continuous rotation
	_start_lock_ring_rotation()

func _animate_lock_ring_out():
	if not lock_ring:
		return
		
	# Stop any existing animation
	if lock_animation_tween:
		lock_animation_tween.kill()
	
	lock_animation_tween = create_tween()
	
	# Scale and fade out
	lock_animation_tween.set_parallel(true)
	lock_animation_tween.tween_property(lock_ring, "scale", Vector2(0.1, 0.1), 0.2).set_ease(Tween.EASE_IN)
	lock_animation_tween.tween_property(lock_ring, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)
	
	# Hide after animation
	lock_animation_tween.tween_callback(func(): lock_ring.visible = false)

func _start_lock_ring_rotation():
	if not lock_ring or not lock_ring.visible:
		return
		
	# Create a continuous rotation animation
	var rotation_tween = create_tween()
	rotation_tween.set_loops()  # Infinite loop
	rotation_tween.tween_property(lock_ring, "rotation", lock_ring.rotation + TAU, 2.0)

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("players")
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		# Handle firing
		fire_timer += delta
		if fire_timer >= fire_interval:
			fire_timer = 0.0
			shoot_at(player)

func shoot_at(player: Node2D):
	if not projectile_scene:
		return
	var bullet = projectile_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int):
	health -= amount

	if damage_number_scene:
		var dmg_number = damage_number_scene.instantiate()
		dmg_number.text = str(amount)
		dmg_number.global_position = global_position
		get_tree().current_scene.add_child(dmg_number)

	if health <= 0:
		_spawn_explosion_effect()
		grant_kill_reward()
		enemy_killed.emit()  # Emit signal when killed
		queue_free()

func _spawn_explosion_effect():
	# Spawn particle effect at enemy position
	var explosion_scene = preload("res://scenes/game/enemy_explosion_particles.tscn")
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)

func grant_kill_reward():
	var reward = 5  # or scale by difficulty later
	var scrap_reward = 3  # base scrap reward
	PlayerData.credits += reward
	PlayerData.add_scrap(scrap_reward)
	# Don't save here - only save on successful escape
	print("Enemy destroyed. +", reward, " credits, +", scrap_reward, " scrap. (Progress will be saved on escape)")


func _input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		print("Enemy tapped:", self.name)
		var player = get_tree().get_first_node_in_group("players")
		if player and player.has_method("lock_on_target"):
			player.lock_on_target(self)
