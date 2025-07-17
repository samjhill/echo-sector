extends Control

func _ready():
	PlayerData.load_game()
	$VBoxContainer/CreditsLabel.text = "Credits: " + str(PlayerData.credits)

	$VBoxContainer/LaunchButton.pressed.connect(_on_launch_pressed)

func _on_launch_pressed():
	# Replace with your actual Abyss run scene path
	get_tree().change_scene_to_file("res://node_2d.tscn")
