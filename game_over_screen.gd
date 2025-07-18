extends CanvasLayer

func _ready():
	$VBoxContainer/Button.pressed.connect(_on_return_pressed)

func _on_return_pressed():
	get_tree().change_scene_to_file("res://hangar.tscn")
