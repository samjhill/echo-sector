extends Control

@export var credits_earned: int = 0
var enemies_killed: int = 0
var scrap_earned: int = 0

func _ready():
	# Create statistics labels if they don't exist
	_create_statistics_labels()
	
	# Update statistics labels
	_update_statistics_display()
	
	# Connect button
	$MainContainer/ReturnButton.pressed.connect(_on_return_pressed)

func _create_statistics_labels():
	var main_container = $MainContainer
	
	# Check if labels already exist
	var enemies_label = main_container.get_node_or_null("EnemiesKilledLabel")
	var credits_label = main_container.get_node_or_null("CreditsEarnedLabel")
	var scrap_label = main_container.get_node_or_null("ScrapCollectedLabel")
	
	# Get the index where we want to insert the labels (after Spacer2)
	var spacer2 = main_container.get_node("Spacer2")
	var insert_index = spacer2.get_index() + 1
	
	# Create enemies killed label if it doesn't exist
	if not enemies_label:
		enemies_label = Label.new()
		enemies_label.name = "EnemiesKilledLabel"
		enemies_label.layout_mode = 2
		enemies_label.add_theme_font_size_override("font_size", 26)
		enemies_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		enemies_label.add_theme_color_override("font_color", Color(1, 0.6, 0.6, 1))
		main_container.add_child(enemies_label)
		main_container.move_child(enemies_label, insert_index)
		insert_index += 1
	
	# Create credits earned label if it doesn't exist
	if not credits_label:
		credits_label = Label.new()
		credits_label.name = "CreditsEarnedLabel"
		credits_label.layout_mode = 2
		credits_label.add_theme_font_size_override("font_size", 26)
		credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		credits_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
		main_container.add_child(credits_label)
		main_container.move_child(credits_label, insert_index)
		insert_index += 1
	
	# Create scrap collected label if it doesn't exist
	if not scrap_label:
		scrap_label = Label.new()
		scrap_label.name = "ScrapCollectedLabel"
		scrap_label.layout_mode = 2
		scrap_label.add_theme_font_size_override("font_size", 26)
		scrap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scrap_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
		main_container.add_child(scrap_label)
		main_container.move_child(scrap_label, insert_index)

func _update_statistics_display():
	var main_container = $MainContainer
	
	# Update enemies killed label
	var enemies_label = main_container.get_node_or_null("EnemiesKilledLabel")
	if enemies_label:
		enemies_label.text = "Enemies Destroyed: " + str(enemies_killed)
	
	# Update credits earned label
	var credits_label = main_container.get_node_or_null("CreditsEarnedLabel")
	if credits_label:
		credits_label.text = "Credits Earned: " + str(credits_earned)
	
	# Update scrap collected label
	var scrap_label = main_container.get_node_or_null("ScrapCollectedLabel")
	if scrap_label:
		scrap_label.text = "Scrap Collected: " + str(scrap_earned)

func _on_return_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://scenes/menus/hangar.tscn")
