extends Area2D

@export var speed: float = 400.0
@export var damage: int = 1
var direction: Vector2 = Vector2.ZERO

func _ready():
	print("Spawned with direction: ", direction)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if not is_instance_valid(body):
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
