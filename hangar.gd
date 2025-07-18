extends Control

func _ready():
	PlayerData.load_game()
	$VBoxContainer/BuildLabel.text = "Build: " + BuildVersion.BUILD_VERSION + " - " + BuildVersion.BUILD_TIMESTAMP
	$VBoxContainer/CreditsLabel.text = "Credits: " + str(PlayerData.credits)

	$VBoxContainer/LaunchButton.pressed.connect(_on_launch_pressed)

func _on_launch_pressed():
	# Replace with your actual Abyss run scene path
	get_tree().change_scene_to_file("res://node_2d.tscn")
