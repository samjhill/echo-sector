extends CanvasLayer

func _ready():
	$VBoxContainer/Button.pressed.connect(_on_return_pressed)

func _on_return_pressed():
	print("is paused? ", get_tree().paused)
	print("returning to hangar screen")

	self.queue_free()  # remove the Game Over screen
	call_deferred("change_to_hangar")

	
func change_to_hangar():
	print("hangar scene exists?", ResourceLoader.exists("res://hangar.tscn"))
	print("Before switch:", get_tree().current_scene)

	get_tree().paused = false  # just in case it’s paused
	var error = get_tree().change_scene_to_file("res://hangar.tscn")

	if error == OK:
		print("Scene changed to hangar.")
	else:
		print("Failed to switch to hangar. Error code:", error)
