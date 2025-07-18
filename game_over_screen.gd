extends CanvasLayer

func _ready():
	$VBoxContainer/Button.pressed.connect(_on_return_pressed)

func _on_return_pressed():
	print("is paused? ", get_tree().paused)
	print("returning to hangar screen")
	call_deferred("change_to_hangar")
	
func change_to_hangar():
	print("hangar scene exists?", ResourceLoader.exists("res://hangar.tscn"))
	print("Before switch:", get_tree().current_scene)

	var hangar_scene = load("res://hangar.tscn")
	if hangar_scene:
		var hangar_instance = hangar_scene.instantiate()
		hangar_instance.visible = true

		# Remove all current root children to fully reset the scene tree
		for child in get_tree().root.get_children():
			child.queue_free()

		get_tree().root.add_child(hangar_instance)
		get_tree().current_scene = hangar_instance

		print("Scene manually loaded and set as current.")
		print("After switch:", get_tree().current_scene)
	else:
		print("Failed to load hangar.tscn")
