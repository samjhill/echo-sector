extends Label

@export var float_speed := 50.0
@export var fade_time := 0.75

var elapsed := 0.0

func _ready():
	modulate.a = 1.0

func _process(delta):
	elapsed += delta
	position.y -= float_speed * delta
	modulate.a = 1.0 - (elapsed / fade_time)

	if elapsed >= fade_time:
		queue_free()
