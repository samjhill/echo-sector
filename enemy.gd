extends CharacterBody2D

@export var speed: float = 100.0
@export var max_health: int = 3
@export var color: Color = Color.RED
@onready var sprite := $Sprite2D
@export var damage_number_scene: PackedScene

var health: int

func _ready():
	health = max_health
	sprite.modulate = color
	add_to_group("enemies")

func set_locked(is_locked: bool):
	print("set_locked called on ", self.name, " — locked: ", is_locked)
	$LockRing.visible = is_locked

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("players")
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amount: int):
	health -= amount

	if damage_number_scene:
		var dmg_number = damage_number_scene.instantiate()
		dmg_number.text = str(amount)
		dmg_number.global_position = global_position
		get_tree().current_scene.add_child(dmg_number)

	if health <= 0:
		grant_kill_reward()
		queue_free()

func grant_kill_reward():
	var reward = 5  # or scale by difficulty later
	PlayerData.credits += reward
	PlayerData.save_game()
	print("Enemy destroyed. +", reward, " credits. Total:", PlayerData.credits)


func _input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		print("Enemy tapped:", self.name)
		var player = get_tree().get_first_node_in_group("players")
		if player and player.has_method("lock_on_target"):
			player.lock_on_target(self)
