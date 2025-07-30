# StellarGridUI.gd
# UI controller for the Stellar Grid system
extends Control

signal item_placed_on_grid(grid_position: Vector2i, item: Item)
signal item_removed_from_grid(grid_position: Vector2i, item: Item)

# UI References
var grid_container: GridContainer
var inventory_panel: Panel
var production_display: Label
var grid_info_label: Label
var close_button: Button

# Grid management
var grid_manager: GridManager
var grid_tile_buttons: Array[Array] = []
var selected_item: Item = null
var drag_preview: TextureRect

# Mobile-friendly removal system
var long_press_timer: Timer
var long_press_duration: float = 0.8  # 800ms for long press
var pressed_tile: Vector2i = Vector2i(-1, -1)
var is_long_pressing: bool = false

# Grid configuration
var grid_size: Vector2i = Vector2i(3, 3)  # Start with 3x3
const TILE_SIZE := 60

func _ready():
	# Get references manually since scene is loaded dynamically
	grid_container = $MainContainer/Content/TopRow/GridSection/GridContainer
	inventory_panel = $MainContainer/Content/InventorySection/InventoryPanel
	production_display = $MainContainer/Content/TopRow/InfoSection/ProductionDisplay
	grid_info_label = $MainContainer/Content/TopRow/InfoSection/GridInfoLabel
	close_button = $MainContainer/Header/CloseButton
	
	print("Grid container found: ", grid_container != null)
	print("Inventory panel found: ", inventory_panel != null)
	print("Production display found: ", production_display != null)
	print("Grid info label found: ", grid_info_label != null)
	print("Close button found: ", close_button != null)
	
	setup_grid_manager()
	create_grid_ui()
	setup_inventory_display()
	connect_signals()
	setup_long_press_system()
	
	# Check if tutorial should be shown
	if not PlayerData.get_tutorial_completed("stellar_grid", false):
		start_tutorial()
	else:
		print("Tutorial already completed, skipping...")

func setup_grid_manager():
	"""Initialize the grid manager"""
	grid_manager = GridManager.new()
	grid_manager.production_tick_completed.connect(_on_production_tick)
	grid_manager.tile_placed.connect(_on_tile_placed)
	grid_manager.tile_removed.connect(_on_tile_removed)
	add_child(grid_manager)
	
	# Wait a frame for the grid manager to load data, then refresh UI
	await get_tree().process_frame
	refresh_grid_ui()

func refresh_grid_ui():
	"""Refresh the grid UI to match the current grid state"""
	create_grid_ui()
	update_grid_display()
	update_grid_info()

func create_grid_ui():
	"""Create the visual grid UI"""
	# Get grid size from grid manager
	if grid_manager != null:
		grid_size = grid_manager.grid_size
	
	# Clear existing grid UI
	clear_grid_ui()
	
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

func clear_grid_ui():
	"""Clear the existing grid UI"""
	# Remove existing tile buttons
	for child in grid_container.get_children():
		child.queue_free()
	
	# Clear the buttons array
	grid_tile_buttons.clear()

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
	
	# Connect signals for mobile-friendly interaction
	button.pressed.connect(_on_tile_button_pressed.bind(grid_position))
	button.gui_input.connect(_on_tile_gui_input.bind(grid_position))
	
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

func setup_long_press_system():
	"""Setup the long press timer for mobile-friendly removal"""
	long_press_timer = Timer.new()
	long_press_timer.wait_time = long_press_duration
	long_press_timer.one_shot = true
	long_press_timer.timeout.connect(_on_long_press_timeout)
	add_child(long_press_timer)

func update_inventory_display():
	"""Update the inventory display with grid-compatible items"""
	# Debug: check if inventory panel exists
	if inventory_panel == null:
		print("ERROR: inventory_panel is null!")
		return
	
	print("Inventory panel found: ", inventory_panel.name)
	
	# Clear existing inventory display
	var inventory_vbox = inventory_panel.get_node("InventoryScroll/InventoryVBox")
	if inventory_vbox != null:
		for child in inventory_vbox.get_children():
			if child.has_method("queue_free"):
				child.queue_free()
		
		# Create inventory items display
		var grid_items = get_grid_compatible_items()
		print("Found ", grid_items.size(), " grid-compatible items in inventory")
		for item in grid_items:
			print("  - ", item.name, " (", item.type, ")")
			var item_button = create_inventory_item_button(item)
			inventory_vbox.add_child(item_button)
	else:
		print("ERROR: Could not find InventoryVBox in inventory panel")
		# Try alternative path
		inventory_vbox = inventory_panel.get_node("InventoryScroll/InventoryVBox")
		if inventory_vbox != null:
			print("Found inventory vbox with alternative path")
			for child in inventory_vbox.get_children():
				if child.has_method("queue_free"):
					child.queue_free()
			
			var grid_items = get_grid_compatible_items()
			print("Found ", grid_items.size(), " grid-compatible items in inventory")
			for item in grid_items:
				print("  - ", item.name, " (", item.type, ")")
				var item_button = create_inventory_item_button(item)
				inventory_vbox.add_child(item_button)
		else:
			print("ERROR: Could not find InventoryVBox with any path")
			# Debug: print the actual structure
			print("Inventory panel children:")
			for child in inventory_panel.get_children():
				print("  - ", child.name, " (", child.get_class(), ")")
				if child.name == "InventoryScroll":
					print("    InventoryScroll children:")
					for grandchild in child.get_children():
						print("      - ", grandchild.name, " (", grandchild.get_class(), ")")

func get_grid_compatible_items() -> Array[Item]:
	"""Get items from inventory that can be placed on the grid"""
	var compatible_items: Array[Item] = []
	
	print("Checking inventory for grid-compatible items...")
	print("Total inventory items: ", PlayerData.inventory.size())
	
	# Debug: print all inventory items
	for i in range(PlayerData.inventory.size()):
		var item = PlayerData.inventory[i]
		if item != null:
			print("  Item ", i, ": ", item.name, " (type: ", item.type, ", slot_type: ", item.slot_type, ")")
			if item.type == "grid_module":
				compatible_items.append(item)
				print("    -> Added to grid-compatible items")
		else:
			print("  Item ", i, ": null")
	
	print("Total grid-compatible items: ", compatible_items.size())
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
	elif grid_manager.get_tile(grid_position) != null and grid_manager.get_tile(grid_position).is_occupied():
		# Show info about the placed item
		var tile = grid_manager.get_tile(grid_position)
		var item = tile.get_item()
		print("Tile at ", grid_position, " contains: ", item.name)
	else:
		print("No item selected and tile is empty")

func _on_tile_gui_input(event: InputEvent, grid_position: Vector2i):
	"""Handle mobile-friendly input for tile interaction"""
	if event is InputEventScreenTouch:
		var touch_event = event as InputEventScreenTouch
		if touch_event.pressed:
			# Start long press timer
			pressed_tile = grid_position
			is_long_pressing = false
			long_press_timer.start()
			# Visual feedback for long press start
			show_long_press_indicator(grid_position, true)
		else:
			# Touch released
			if not is_long_pressing:
				# Short press - handle normally
				_on_tile_button_pressed(grid_position)
			# Reset long press state
			pressed_tile = Vector2i(-1, -1)
			is_long_pressing = false
			long_press_timer.stop()
			# Remove visual feedback
			show_long_press_indicator(grid_position, false)
	elif event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
			# Right click - remove item
			remove_item_from_tile(grid_position)
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			# Left click - handle normally
			_on_tile_button_pressed(grid_position)

func _on_long_press_timeout():
	"""Handle long press timeout for item removal"""
	if pressed_tile != Vector2i(-1, -1):
		is_long_pressing = true
		remove_item_from_tile(pressed_tile)
		show_removal_feedback(pressed_tile)

func remove_item_from_tile(grid_position: Vector2i):
	"""Remove item from a grid tile"""
	var tile = grid_manager.get_tile(grid_position)
	if tile != null and tile.is_occupied():
		var removed_item = grid_manager.remove_item(grid_position)
		if removed_item != null:
			print("Removed ", removed_item.name, " from position ", grid_position)
			# Add item back to inventory
			PlayerData.add_item_to_inventory(removed_item)
			update_grid_display()
			update_inventory_display()
			show_removal_feedback(grid_position)
		else:
			print("Failed to remove item from position ", grid_position)
	else:
		print("No item to remove at position ", grid_position)

func show_removal_feedback(grid_position: Vector2i):
	"""Show visual feedback for item removal"""
	# Create a temporary visual feedback
	var feedback = ColorRect.new()
	feedback.color = Color.RED
	feedback.modulate.a = 0.5
	feedback.anchor_right = 1.0
	feedback.anchor_bottom = 1.0
	
	var tile_button = grid_tile_buttons[grid_position.x][grid_position.y]
	tile_button.add_child(feedback)
	
	# Animate the feedback
	var tween = create_tween()
	tween.tween_property(feedback, "modulate:a", 0.0, 0.5)
	tween.tween_callback(feedback.queue_free)

func show_long_press_indicator(grid_position: Vector2i, show: bool):
	"""Show/hide visual indicator for long press"""
	var tile_button = grid_tile_buttons[grid_position.x][grid_position.y]
	if tile_button == null:
		return
	
	# Remove existing indicator
	var existing_indicator = tile_button.get_node_or_null("LongPressIndicator")
	if existing_indicator != null:
		existing_indicator.queue_free()
	
	if show:
		# Create new indicator
		var indicator = ColorRect.new()
		indicator.name = "LongPressIndicator"
		indicator.color = Color.ORANGE
		indicator.modulate.a = 0.3
		indicator.anchor_right = 1.0
		indicator.anchor_bottom = 1.0
		tile_button.add_child(indicator)
		
		# Animate the indicator
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(indicator, "modulate:a", 0.6, 0.4)
		tween.tween_property(indicator, "modulate:a", 0.3, 0.4)

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
	
	# Check if grid_tile_buttons array is valid for this position
	if grid_position.x >= grid_tile_buttons.size() or grid_position.y >= grid_tile_buttons[0].size():
		print("Warning: Grid position ", grid_position, " is out of bounds for UI buttons")
		return
	
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

func start_tutorial():
	"""Start the tutorial if not completed"""
	print("Starting Stellar Grid tutorial...")
	
	# Create a simple tutorial overlay
	var tutorial_overlay = ColorRect.new()
	tutorial_overlay.color = Color(0, 0, 0, 0.7)
	tutorial_overlay.anchor_right = 1.0
	tutorial_overlay.anchor_bottom = 1.0
	add_child(tutorial_overlay)
	
	var tutorial_panel = Panel.new()
	tutorial_panel.anchor_left = 0.15
	tutorial_panel.anchor_right = 0.85
	tutorial_panel.anchor_top = 0.2
	tutorial_panel.anchor_bottom = 0.8
	tutorial_overlay.add_child(tutorial_panel)
	
	var tutorial_text = Label.new()
	tutorial_text.text = "Welcome to the Stellar Grid!\n\nThis is your space station's power and research hub. You have 3 starter modules:\n\n• Power Core: Generates credits\n• Extractor: Processes scrap\n• Research Lab: Creates blueprint fragments\n\n📱 Mobile Controls:\n• Tap to place modules\n• Long press (0.8s) to remove modules\n• Right-click to remove (desktop)\n\nClick on a module, then click on an empty grid tile to place it!"
	tutorial_text.anchor_left = 0.05
	tutorial_text.anchor_right = 0.95
	tutorial_text.anchor_top = 0.05
	tutorial_text.anchor_bottom = 0.75
	tutorial_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	tutorial_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	tutorial_panel.add_child(tutorial_text)
	
	var close_button = Button.new()
	close_button.text = "Got it!"
	close_button.anchor_left = 0.3
	close_button.anchor_right = 0.7
	close_button.anchor_top = 0.8
	close_button.anchor_bottom = 0.9
	close_button.pressed.connect(func(): 
		tutorial_overlay.queue_free()
		_on_tutorial_completed()
	)
	tutorial_panel.add_child(close_button)

func _on_tutorial_completed():
	"""Handle tutorial completion"""
	print("Tutorial completed!")
	PlayerData.set_tutorial_completed("stellar_grid", true)

func _on_close_button_pressed():
	"""Handle close button press"""
	visible = false 
