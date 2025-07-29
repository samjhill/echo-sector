extends Node

@onready var credits_label = $"../UI/ResourcesPanel/CreditsLabel"
@onready var scrap_label = $"../UI/ResourcesPanel/ScrapLabel"

func _ready():
	# Update UI with current values
	update_resource_display()
	
	# Connect to PlayerData signals if they exist
	if PlayerData.has_signal("credits_changed"):
		PlayerData.credits_changed.connect(_on_credits_changed)
	if PlayerData.has_signal("scrap_changed"):
		PlayerData.scrap_changed.connect(_on_scrap_changed)

func _process(_delta):
	# Update display every frame to ensure it's current
	update_resource_display()

func update_resource_display():
	if credits_label:
		credits_label.text = "Credits: " + str(PlayerData.credits)
	if scrap_label:
		scrap_label.text = "Scrap: " + str(PlayerData.scrap)

func _on_credits_changed():
	if credits_label:
		credits_label.text = "Credits: " + str(PlayerData.credits)

func _on_scrap_changed():
	if scrap_label:
		scrap_label.text = "Scrap: " + str(PlayerData.scrap) 