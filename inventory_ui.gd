extends Control

@onready var item_grid: GridContainer = $ItemGrid
@onready var tooltip_panel: Panel = $Tooltip
@onready var tooltip_label: Label = $Tooltip/Label

func _ready():
	update_inventory()

func update_inventory():
	# Clear existing item buttons
	for child in item_grid.get_children():
		child.queue_free()

	for item in PlayerData.inventory:
		var item_button = TextureButton.new()
		item_button.texture_normal = item.icon
		#item_button.expand = true
		item_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

		item_button.set_meta("item", item)
		item_button.pressed.connect(_on_item_button_pressed.bind(item))
		item_grid.add_child(item_button)

	tooltip_panel.visible = false


func _on_item_button_pressed(item):
	tooltip_label.text = "%s\n\n%s" % [item.name, item.description]
	tooltip_panel.visible = true

	# Optionally auto-hide the tooltip after a few seconds:
	# await get_tree().create_timer(3.0).timeout
	# tooltip_panel.visible = false
