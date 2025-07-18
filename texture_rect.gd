extends TextureRect

@export var scroll_speed: float = 20.0 # pixels per second

var start_position: Vector2
var max_offset: float

func _ready():
	start_position = position
	var texture_width = texture.get_width()
	var visible_width = get_rect().size.x
	max_offset = texture_width - visible_width
	set_clip_contents(true)

func _process(delta):
	if position.x < -(max_offset):
		print("moving")
		position.x -= scroll_speed * delta
	else:
		print("bg x", position.x)
		print("offset", -(max_offset))
