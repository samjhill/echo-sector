# enemy_projectile.gd
extends Area2D

@export var color: Color = Color.RED
@export var speed := 300.0
@onready var sprite := $Sprite2D

var direction := Vector2.ZERO

func _ready():
	sprite.modulate = color
	
func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	print("Projectile hit:", body)
	if body.is_in_group("players"):
		print("!~ player hit")
		body.take_damage(1) 
		queue_free()
	else:
		print(body.get_groups())
		
func _on_screen_exited():
	queue_free()
