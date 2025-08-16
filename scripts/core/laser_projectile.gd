extends Area2D

@export var speed := 800.0
@export var direction := Vector2.RIGHT
@export var damage := 10
@export var lifetime := 3.0  # seconds
@export var slot_type: String = "weapon"

func _ready():
	$Timer.wait_time = lifetime
	$Timer.start()

func _physics_process(delta):
	position += direction.normalized() * speed * delta
	
func _on_body_entered(body):
	print("Laser hit body: ", body)
	if not is_instance_valid(body) or body == self:
		print("Invalid body or self, skipping")
		return
		
	if body.has_method("take_damage") and body.is_in_group("enemies"):
		print("Dealing laser damage to enemy: ", body.name)
		body.take_damage(damage)
		# Disable further monitoring and free safely after signal emission
		set_deferred("monitoring", false)
		var shape = get_node_or_null("CollisionShape2D")
		if shape:
			shape.set_deferred("disabled", true)
		call_deferred("queue_free")
	else:
		print("Body has no take_damage method or not an enemy: ", body.get_groups())

func _on_Timer_timeout():
	queue_free()
