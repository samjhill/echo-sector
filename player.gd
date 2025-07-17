extends CharacterBody2D
@export var projectile_scene: PackedScene
@export var speed: float = 300.0
@export var fire_interval: float = 0.5
@export var move_speed := 200.0
@export var rotation_speed := 5.0
@export var orbit_radius := 180.0
@export var orbit_speed := 1.0  # radians per second

@onready var camera = $Camera2D

var target_position: Vector2
var moving_to_target := false
var orbiting := false
var orbit_angle := 0.0


var current_target: Node2D = null
var fire_timer: float = 0.0

func _ready():
	set_process_input(true)
	add_to_group("players")

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target_position = event.position
		moving_to_target = true
	elif event is InputEventMouseButton and event.pressed:
		target_position = event.position
		moving_to_target = true
		

func _set_target(pos: Vector2):
	target_position = pos
	moving_to_target = true
	orbiting = false
	orbit_angle = 0.0
	
func _physics_process(delta):
	if orbiting:
		camera.enabled = false  # Freeze camera
		orbit_angle += orbit_speed * delta
		var orbit_offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
		var desired_position = target_position + orbit_offset
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

		if distance > orbit_radius * 0.9:
			direction = direction.normalized()
			rotation = lerp_angle(rotation, direction.angle(), rotation_speed * delta)
			velocity = direction * move_speed
		else:
			moving_to_target = false
			orbiting = true
			orbit_angle = (global_position - target_position).angle()
	else:
		camera.enabled = true  # unfreeze camera
		var input_vector = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized()

		velocity = input_vector * move_speed
		if input_vector == Vector2.ZERO:
			velocity = Vector2.ZERO

	move_and_slide()


func _process(delta):
	if current_target and is_instance_valid(current_target):
		fire_timer += delta
		if fire_timer >= fire_interval:
			fire_timer = 0.0
			shoot_at_target(current_target)
	else:
		current_target = null

func shoot_at_target(target: Node2D):
	if not projectile_scene:
		print("No projectile scene assigned")
		return

	var bullet = projectile_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (target.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func lock_on_target(target: Node2D):
	if current_target and current_target.has_method("set_locked"):
		current_target.set_locked(false)

	if current_target == target:
		current_target = null  # Unlock if tapped again
	else:
		current_target = target
		fire_timer = 0.0  # Reset cooldown
		if current_target.has_method("set_locked"):
			current_target.set_locked(true)
