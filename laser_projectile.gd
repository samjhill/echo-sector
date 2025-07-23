extends Area2D

@export var speed := 800.0
@export var direction := Vector2.RIGHT
@export var damage := 10
@export var lifetime := 2.0  # seconds
@export var slot_type: String = "weapon"

func _ready():
	$Timer.wait_time = lifetime
	$Timer.start()
	#connect("body_entered", _on_body_entered)

func _physics_process(delta):
	position += direction.normalized() * speed * delta
	
func _on_body_entered(body):
	print("hit", body)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()  # Destroy the laser after hitting

func _on_Timer_timeout():
	queue_free()
