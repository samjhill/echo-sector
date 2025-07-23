extends Area2D

@export var speed := 800.0
@export var direction := Vector2.RIGHT
@export var damage := 10
@export var lifetime := 2.0  # seconds

func _ready():
	$Timer.wait_time = lifetime
	$Timer.start()
	connect("area_entered", _on_area_entered)

func _physics_process(delta):
	position += direction.normalized() * speed * delta

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		area.take_damage(damage)
	queue_free()

func _on_Timer_timeout():
	queue_free()
