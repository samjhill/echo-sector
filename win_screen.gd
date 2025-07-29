extends Control

@export var credits_earned: int = 0
var enemies_killed: int = 0
var scrap_earned: int = 0

func _ready():
	$VBoxContainer/VictoryLabel.text = "Mission Complete!"
	$VBoxContainer/RewardLabel.text = "You earned " + str(credits_earned) + " credits"
	
	# Add run statistics
	var stats_text = ""
	stats_text += "Enemies Destroyed: " + str(enemies_killed) + "\n"
	stats_text += "Credits Earned: " + str(credits_earned) + "\n"
	stats_text += "Scrap Collected: " + str(scrap_earned)
	
	# Create a new label for statistics
	var stats_label = Label.new()
	stats_label.text = stats_text
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 20)
	stats_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
	
	# Insert the stats label before the return button
	var vbox = $VBoxContainer
	var return_button = vbox.get_node("ReturnButton")
	var button_index = return_button.get_index()
	vbox.add_child(stats_label)
	vbox.move_child(stats_label, button_index)
	
	$VBoxContainer/ReturnButton.pressed.connect(_on_return_pressed)

func _on_return_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://hangar.tscn")
