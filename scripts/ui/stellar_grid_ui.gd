# StellarGridUI.gd
# UI controller for the Stellar Grid system
extends Control

signal item_placed_on_grid(grid_position: Vector2i, item: Item)
signal item_removed_from_grid(grid_position: Vector2i, item: Item)

# UI References
@onready var grid_container: GridContainer = $MainContainer/Content/TopRow/GridSection/GridContainer
@onready var inventory_panel: Panel = $MainContainer/Content/InventorySection/InventoryPanel
@onready var production_display: Label = $MainContainer/Content/TopRow/InfoSection/ProductionDisplay
@onready var grid_info_label: Label = $MainContainer/Content/TopRow/InfoSection/GridInfoLabel
@onready var close_button: Button = $MainContainer/Header/CloseButton

# Grid management
var grid_manager: GridManager
var grid_tile_buttons: Array[Array] = []
var selected_item: Item = null
var drag_preview: TextureRect

# Grid configuration
var grid_size: Vector2i = Vector2i(3, 3)  # Start with 3x3
const TILE_SIZE := 60

func _ready():
	setup_grid_manager()
	create_grid_ui()
	setup_inventory_display()
	connect_signals()

func setup_grid_manager():
	"""Initialize the grid manager"""
	grid_manager = GridManager.new()
	grid_manager.production_tick_completed.connect(_on_production_tick)
	grid_manager.tile_placed.connect(_on_tile_placed)
	grid_manager.tile_removed.connect(_on_tile_removed)
	add_child(grid_manager)

func create_grid_ui():
	"""Create the visual grid UI"""
	# Get grid size from grid manager
	if grid_manager != null:
		grid_size = grid_manager.grid_size
	
	grid_container.columns = grid_size.x
	
	# Initialize grid tile buttons array
	grid_tile_buttons.resize(grid_size.x)
	for x in range(grid_size.x):
		grid_tile_buttons[x] = []
		grid_tile_buttons[x].resize(grid_size.y)
		
		for y in range(grid_size.y):
			var tile_button = create_tile_button(Vector2i(x, y))
			grid_container.add_child(tile_button)
			grid_tile_buttons[x][y] = tile_button

func create_tile_button(grid_position: Vector2i) -> Button:
	"""Create a button for a grid tile"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(TILE_SIZE, TILE_SIZE)
	button.text = "Empty"
	button.name = "Tile_" + str(grid_position.x) + "_" + str(grid_position.y)
	
	# Style the button
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.YELLOW)
	
	# Connect signals
	button.pressed.connect(_on_tile_button_pressed.bind(grid_position))
	button.mouse_entered.connect(_on_tile_hovered.bind(grid_position))
	button.mouse_exited.connect(_on_tile_unhovered.bind(grid_position))
	
	return button

func setup_inventory_display():
	"""Setup the inventory display panel"""
	# This will be populated with grid-compatible items from player inventory
	update_inventory_display()

func connect_signals():
	"""Connect all necessary signals"""
	# Connect to player data changes
	PlayerData.inventory_changed.connect(update_inventory_display)
	
	# Connect close button
	if close_button != null:
		close_button.pressed.connect(_on_close_button_pressed)

func update_inventory_display():
	"""Update the inventory display with grid-compatible items"""
	# Clear existing inventory display
	var inventory_vbox = inventory_panel.get_node("InventoryScroll/InventoryVBox")
	if inventory_vbox != null:
		for child in inventory_vbox.get_children():
			if child.has_method("queue_free"):
				child.queue_free()
		
		# Create inventory items display
		var grid_items = get_grid_compatible_items()
		for item in grid_items:
			var item_button = create_inventory_item_button(item)
			inventory_vbox.add_child(item_button)

func get_grid_compatible_items() -> Array[Item]:
	"""Get items from inventory that can be placed on the grid"""
	var compatible_items: Array[Item] = []
	
	for item in PlayerData.inventory:
		if item != null and item.type == "grid_module":
			compatible_items.append(item)
	
	return compatible_items

func create_inventory_item_button(item: Item) -> Button:
	"""Create a button for an inventory item"""
	var button = Button.new()
	button.text = item.name
	button.custom_minimum_size = Vector2(0, 30)
	
	# Style the button
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.YELLOW)
	
	# Connect to drag/drop system
	button.pressed.connect(_on_inventory_item_selected.bind(item))
	
	return button

func _on_tile_button_pressed(grid_position: Vector2i):
	"""Handle tile button press for item placement"""
	if selected_item != null:
		if grid_manager.place_item(grid_position, selected_item):
			selected_item = null
			update_grid_display()
			update_inventory_display()
		else:
			print("Failed to place item at: ", grid_position)

func _on_tile_hovered(grid_position: Vector2i):
	"""Handle tile hover for visual feedback"""
	var tile = grid_manager.get_tile(grid_position)
	if tile != null:
		tile.set_highlight(true)
		update_tile_display(grid_position)

func _on_tile_unhovered(grid_position: Vector2i):
	"""Handle tile unhover"""
	var tile = grid_manager.get_tile(grid_position)
	if tile != null:
		tile.set_highlight(false)
		update_tile_display(grid_position)

func _on_inventory_item_selected(item: Item):
	"""Handle inventory item selection"""
	selected_item = item
	print("Selected item for placement: ", item.name)

func _on_production_tick(resources_generated: Dictionary):
	"""Handle production tick completion"""
	update_production_display(resources_generated)

func _on_tile_placed(grid_position: Vector2i, item: Item):
	"""Handle tile placement event"""
	update_tile_display(grid_position)
	update_grid_info()

func _on_tile_removed(grid_position: Vector2i, item: Item):
	"""Handle tile removal event"""
	update_tile_display(grid_position)
	update_grid_info()

func update_grid_display():
	"""Update the visual display of the entire grid"""
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			update_tile_display(Vector2i(x, y))

func update_tile_display(grid_position: Vector2i):
	"""Update the display of a specific tile"""
	var tile = grid_manager.get_tile(grid_position)
	var button = grid_tile_buttons[grid_position.x][grid_position.y]
	
	if tile == null or button == null:
		return
	
	if tile.is_occupied():
		var item = tile.get_item()
		button.text = item.name
		button.modulate = Color.GREEN
	else:
		button.text = "Empty"
		button.modulate = Color.WHITE
	
	if tile.is_highlighted:
		button.modulate = Color.YELLOW

func update_production_display(resources_generated: Dictionary):
	"""Update the production display with generated resources"""
	var display_text = "Last Production Tick:\n"
	
	for resource_type in resources_generated:
		var amount = resources_generated[resource_type]
		if amount > 0:
			display_text += resource_type.capitalize() + ": +" + str(amount) + "\n"
	
	if resources_generated.is_empty():
		display_text += "No resources generated"
	
	production_display.text = display_text

func update_grid_info():
	"""Update the grid information display"""
	var occupied_tiles = 0
	var total_tiles = grid_size.x * grid_size.y
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var tile = grid_manager.get_tile(Vector2i(x, y))
			if tile != null and tile.is_occupied():
				occupied_tiles += 1
	
	var info_text = "Grid Status:\n"
	info_text += "Occupied: " + str(occupied_tiles) + "/" + str(total_tiles) + "\n"
	info_text += "Efficiency: " + str(round((float(occupied_tiles) / float(total_tiles)) * 100)) + "%"
	
	grid_info_label.text = info_text

func _input(event):
	"""Handle input for drag and drop system"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Handle click events
			pass
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Handle right-click for item removal
			handle_right_click()

func handle_right_click():
	"""Handle right-click for item removal from grid"""
	# This would be implemented to remove items from tiles
	# For now, just a placeholder
	pass

func _on_close_button_pressed():
	"""Handle close button press"""
	visible = false 
