extends Node

@onready var credits_label = $"../UI/ResourcesPanel/CreditsLabel"
@onready var scrap_label = $"../UI/ResourcesPanel/ScrapLabel"
@onready var heal_button = $"../UI/HealButton"

var heal_cost := 15  # Scrap cost for repair (increased from 5)

func _ready():
	# Update UI with current values
	update_resource_display()
	update_heal_button()
	
	# Connect to PlayerData signals if they exist
	if PlayerData.has_signal("credits_changed"):
		PlayerData.credits_changed.connect(_on_credits_changed)
	if PlayerData.has_signal("scrap_changed"):
		PlayerData.scrap_changed.connect(_on_scrap_changed)
	
	# Connect heal button
	if heal_button:
		heal_button.pressed.connect(_on_heal_button_pressed)

func _process(_delta):
	# Update display every frame to ensure it's current
	update_resource_display()
	update_heal_button()

func update_resource_display():
	if credits_label:
		credits_label.text = "Credits: " + str(PlayerData.credits)
	if scrap_label:
		scrap_label.text = "Scrap: " + str(PlayerData.scrap)

func update_heal_button():
	if heal_button:
		# Check if player can afford healing
		var can_afford = PlayerData.scrap >= heal_cost
		var player = get_tree().get_first_node_in_group("players")
		var needs_healing = false
		
		if player and player.has_method("get_current_health"):
			var current_health = player.get_current_health()
			var max_health = player.get_max_health()
			needs_healing = current_health < max_health
		
		# Enable/disable button based on affordability and need
		heal_button.disabled = not can_afford or not needs_healing
		
		# Update button text with cost
		heal_button.text = "🔧 REPAIR (" + str(heal_cost) + " Scrap)"
		
		# Change color based on state
		if not can_afford:
			heal_button.modulate = Color(0.5, 0.5, 0.5, 1)  # Grayed out
		elif not needs_healing:
			heal_button.modulate = Color(0.3, 0.8, 0.3, 1)  # Green (full health)
		else:
			heal_button.modulate = Color(1, 0.3, 0.3, 1)  # Red (needs repair)

func _on_heal_button_pressed():
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		return
	
	# Check if player can afford it
	if PlayerData.scrap < heal_cost:
		print("Not enough scrap for repair!")
		return
	
	# Check if player needs healing
	if player.has_method("get_current_health") and player.has_method("get_max_health"):
		var current_health = player.get_current_health()
		var max_health = player.get_max_health()
		
		if current_health >= max_health:
			print("Ship is already fully repaired!")
			return
		
		# Perform healing (don't save yet - only save on escape)
		PlayerData.scrap -= heal_cost
		# PlayerData.save_game() - removed, only save on successful escape
		
		# Heal the player
		if player.has_method("heal"):
			player.heal(1)  # Heal 1 health point
			print("Ship repaired! Cost: " + str(heal_cost) + " scrap (will be saved on escape)")
		else:
			print("Player doesn't have heal method!")

func _on_credits_changed():
	if credits_label:
		credits_label.text = "Credits: " + str(PlayerData.credits)

func _on_scrap_changed():
	if scrap_label:
		scrap_label.text = "Scrap: " + str(PlayerData.scrap) 