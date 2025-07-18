extends Control

@export var credits_earned: int = 0

func _ready():
	#$VBoxContainer/VictoryLabel.text = "You Escaped!"
	$VBoxContainer/RewardLabel.text = "You earned " + str(credits_earned) + " credits"
	
	$VBoxContainer/ReturnButton.pressed.connect(_on_return_pressed)

func _on_return_pressed():
	queue_free()

	get_tree().change_scene_to_file("res://hangar.tscn")
