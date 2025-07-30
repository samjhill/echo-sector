# StellarGridUI.gd
# UI controller for the Stellar Grid system
extends Control
class_name StellarGridUI

# Grid properties
var grid_size: Vector2i = Vector2i(3, 3)
var grid_manager: GridManager = null
var grid_tile_buttons: Array[Array] = []
var selected_item: Item = null

# UI elements
var grid_container: GridContainer = null
var inventory_panel: Panel = null
var production_display: Label = null
var grid_info_label: Label = null

# Buff visual manager
var buff_visual_manager: BuffVisualManager = null
var buff_toggle_button: Button = null

# Mobile-friendly input
var long_press_timer: Timer
var long_press_duration: float = 0.8
var pressed_tile: Vector2i = Vector2i(-1, -1)
var is_long_pressing: bool = false

func _ready():
	Logger.info("Initializing Stellar Grid UI", "StellarGridUI")
	
	# Initialize buff visual manager
	buff_visual_manager = BuffVisualManager.new()
	add_child(buff_visual_manager)
	
	# Setup long press system for mobile
	setup_long_press_system()
	
	# Setup grid manager
	setup_grid_manager()
	
	# Setup inventory display
	setup_inventory_display()
	
	# Setup close button
	setup_close_button()
	
	# Create grid UI after all setup is complete
	await get_tree().process_frame
	refresh_grid_ui()
	
	# Check for tutorial
	if not PlayerData.get_tutorial_completed("stellar_grid", false):
		start_tutorial()
	
	Logger.info("Stellar Grid UI initialization complete", "StellarGridUI")

func setup_grid_manager():
	"""Setup the grid manager and connect signals"""
	grid_manager = GridManager.new()
	add_child(grid_manager)  # Add as child so timer can work
	
	# Setup buff visual manager with grid manager
	grid_manager.setup_buff_visual_manager(buff_visual_manager)
	
	# Connect signals
	grid_manager.production_tick_completed.connect(_on_production_tick)
	grid_manager.tile_placed.connect(_on_tile_placed)
	grid_manager.tile_removed.connect(_on_tile_removed)
	
	# Setup UI after grid manager is ready
	await get_tree().process_frame
	refresh_grid_ui()

func setup_long_press_system():
	"""Setup long press timer for mobile-friendly item removal"""
	long_press_timer = Timer.new()
	long_press_timer.wait_time = long_press_duration
	long_press_timer.one_shot = true
	long_press_timer.timeout.connect(_on_long_press_timeout)
	add_child(long_press_timer)

func create_grid_ui():
	"""Create the grid UI elements"""
	Logger.info("Creating grid UI", "StellarGridUI")
	clear_grid_ui()
	
	# Debug: check scene structure
	var main_container = $MainContainer
	if main_container:
		Logger.info("MainContainer found", "StellarGridUI")
		var content = main_container.get_node_or_null("Content")
		if content:
			Logger.info("Content found", "StellarGridUI")
			var top_row = content.get_node_or_null("TopRow")
			if top_row:
				Logger.info("TopRow found", "StellarGridUI")
				var grid_section = top_row.get_node_or_null("GridSection")
				if grid_section:
					Logger.info("GridSection found", "StellarGridUI")
					var grid_container_node = grid_section.get_node_or_null("GridContainer")
					if grid_container_node:
						Logger.info("GridContainer found", "StellarGridUI")
					else:
						Logger.error("GridContainer not found in GridSection", "StellarGridUI")
				else:
					Logger.error("GridSection not found in TopRow", "StellarGridUI")
			else:
				Logger.error("TopRow not found in Content", "StellarGridUI")
		else:
			Logger.error("Content not found in MainContainer", "StellarGridUI")
	else:
		Logger.error("MainContainer not found", "StellarGridUI")
	
	# Get grid container reference
	grid_container = $MainContainer/Content/TopRow/GridSection/GridContainer
	if not grid_container:
		Logger.error("Grid container not found", "StellarGridUI")
		# Try alternative paths
		grid_container = get_node_or_null("MainContainer/Content/TopRow/GridSection/GridContainer")
		if not grid_container:
			Logger.error("Grid container not found with alternative path", "StellarGridUI")
			return
		else:
			Logger.info("Grid container found with alternative path", "StellarGridUI")
	else:
		Logger.info("Grid container found", "StellarGridUI")
	
	# Log grid container properties
	Logger.info("Grid container rect: %s" % grid_container.get_rect(), "StellarGridUI")
	Logger.info("Grid container visible: %s" % grid_container.visible, "StellarGridUI")
	Logger.info("Grid container children count: %d" % grid_container.get_child_count(), "StellarGridUI")
	
	# Set grid container to 3x3
	grid_container.columns = 3
	Logger.info("Set grid container to 3 columns", "StellarGridUI")
	
	# Setup buff visual manager with grid container
	if buff_visual_manager:
		buff_visual_manager.setup(grid_manager, grid_container)
		Logger.info("Buff visual manager setup complete", "StellarGridUI")
	
	# Create grid buttons
	Logger.info("Creating %dx%d grid buttons" % [grid_size.x, grid_size.y], "StellarGridUI")
	for x in range(grid_size.x):
		var column: Array[Button] = []
		for y in range(grid_size.y):
			var button = create_tile_button(Vector2i(x, y))
			grid_container.add_child(button)
			column.append(button)
			Logger.debug("Created button for position (%d, %d) - visible: %s" % [x, y, button.visible], "StellarGridUI")
		grid_tile_buttons.append(column)
	
	Logger.info("Created %dx%d grid UI with %d buttons" % [grid_size.x, grid_size.y, grid_tile_buttons.size() * grid_tile_buttons[0].size() if grid_tile_buttons.size() > 0 else 0], "StellarGridUI")
	Logger.info("Grid container final children count: %d" % grid_container.get_child_count(), "StellarGridUI")

func create_tile_button(grid_position: Vector2i) -> Button:
	"""Create a button for a grid tile"""
	var button = Button.new()
	button.text = "Empty"
	button.custom_minimum_size = Vector2(60, 60)
	
	# Style the button
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.YELLOW)
	
	# Connect signals
	button.pressed.connect(_on_tile_button_pressed.bind(grid_position))
	button.gui_input.connect(_on_tile_gui_input.bind(grid_position))
	
	return button

func clear_grid_ui():
	"""Clear all existing grid UI elements"""
	if grid_container:
		for child in grid_container.get_children():
			child.queue_free()
	grid_tile_buttons.clear()

func refresh_grid_ui():
	"""Refresh the entire grid UI"""
	create_grid_ui()
	update_grid_display()
	update_grid_info()
	
	# Update buff visuals after grid UI is refreshed
	if buff_visual_manager:
		buff_visual_manager.update_all_buff_visuals()
		Logger.info("Updated buff visuals after grid UI refresh", "StellarGridUI")

func setup_inventory_display():
	"""Setup the inventory display"""
	Logger.info("Setting up inventory display", "StellarGridUI")
	
	# Get inventory panel reference - fixed path to match scene structure
	inventory_panel = $MainContainer/Content/InventorySection/InventoryPanel
	if not inventory_panel:
		Logger.error("Inventory panel not found", "StellarGridUI")
		Logger.error("Available nodes: %s" % get_children(), "StellarGridUI")
		return
	else:
		Logger.info("Inventory panel found", "StellarGridUI")
	
	# Get production display reference
	production_display = $MainContainer/Content/TopRow/InfoSection/ProductionDisplay
	if not production_display:
		Logger.error("Production display not found", "StellarGridUI")
		# Don't return, as this is not critical
	else:
		Logger.info("Production display found", "StellarGridUI")
	
	# Get grid info label reference
	grid_info_label = $MainContainer/Content/TopRow/InfoSection/GridInfoLabel
	if not grid_info_label:
		Logger.error("Grid info label not found", "StellarGridUI")
		# Don't return, as this is not critical
	else:
		Logger.info("Grid info label found", "StellarGridUI")
	
	# Create buff toggle button
	create_buff_toggle_button()
	
	# Update displays
	update_inventory_display()
	if production_display:
		update_production_display({})
	
	Logger.info("Inventory display setup complete", "StellarGridUI")

func create_buff_toggle_button():
	"""Create a toggle button for buff visuals"""
	buff_toggle_button = Button.new()
	buff_toggle_button.text = "Show Buffs"
	buff_toggle_button.custom_minimum_size = Vector2(100, 30)
	
	# Style the button
	buff_toggle_button.add_theme_font_size_override("font_size", 12)
	buff_toggle_button.add_theme_color_override("font_color", Color.WHITE)
	buff_toggle_button.add_theme_color_override("font_hover_color", Color.YELLOW)
	
	# Connect signal
	buff_toggle_button.pressed.connect(_on_buff_toggle_pressed)
	
	# Add to info section
	var info_section = $MainContainer/Content/TopRow/InfoSection
	if info_section:
		info_section.add_child(buff_toggle_button)
		Logger.info("Buff toggle button created", "StellarGridUI")

func _on_buff_toggle_pressed():
	"""Handle buff toggle button press"""
	if buff_visual_manager:
		buff_visual_manager.toggle_buff_visuals()
		buff_toggle_button.text = "Hide Buffs" if buff_visual_manager.show_buff_visuals else "Show Buffs"
		Logger.info("Buff visuals toggled", "StellarGridUI")

func update_inventory_display():
	"""Update the inventory display with available grid-compatible items"""
	if not inventory_panel:
		Logger.error("Inventory panel not found", "StellarGridUI")
		return
	
	# Get inventory VBox - fixed path to match scene structure
	var inventory_vbox = inventory_panel.get_node_or_null("InventoryScroll/InventoryVBox")
	if not inventory_vbox:
		Logger.error("Inventory VBox not found", "StellarGridUI")
		return
	
	# Clear existing items
	for child in inventory_vbox.get_children():
		child.queue_free()
	
	# Get grid-compatible items
	var compatible_items = get_grid_compatible_items()
	Logger.debug("Found %d grid-compatible items" % compatible_items.size(), "StellarGridUI")
	
	# Create buttons for each item
	for item in compatible_items:
		if item != null:
			var button = create_inventory_item_button(item)
			inventory_vbox.add_child(button)
			Logger.debug("Added inventory item: %s" % item.name, "StellarGridUI")
		else:
			Logger.warning("Found null item in compatible_items", "StellarGridUI")
	
	# If no items available, show a message
	if compatible_items.size() == 0:
		var no_items_label = Label.new()
		no_items_label.text = "No grid modules available"
		no_items_label.add_theme_color_override("font_color", Color.GRAY)
		inventory_vbox.add_child(no_items_label)
		Logger.info("No grid modules available, showing message", "StellarGridUI")

func get_grid_compatible_items() -> Array[Item]:
	"""Get items from inventory that can be placed on the grid"""
	var compatible_items: Array[Item] = []
	
	Logger.debug("Checking inventory for grid-compatible items", "StellarGridUI")
	Logger.debug("Total inventory items: %d" % PlayerData.inventory.size(), "StellarGridUI")
	
	# Debug: print all inventory items
	for i in range(PlayerData.inventory.size()):
		var item = PlayerData.inventory[i]
		if item != null:
			Logger.debug("  Item %d: %s (type: %s, slot_type: %s)" % [i, item.name, item.type, item.slot_type], "StellarGridUI")
			if item.type == "grid_module":
				compatible_items.append(item)
				Logger.debug("    -> Added to grid-compatible items", "StellarGridUI")
		else:
			Logger.debug("  Item %d: null" % i, "StellarGridUI")
	
	Logger.debug("Total grid-compatible items: %d" % compatible_items.size(), "StellarGridUI")
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
			# Remove the item from inventory when successfully placed
			PlayerData.remove_item_from_inventory(selected_item)
			selected_item = null
			update_grid_display()
			update_inventory_display()
		else:
			Logger.warning("Failed to place item at: %s" % grid_position, "StellarGridUI")
	elif grid_manager.get_tile(grid_position) != null and grid_manager.get_tile(grid_position).is_occupied():
		# Show info about the placed item
		var tile = grid_manager.get_tile(grid_position)
		var item = tile.get_item()
		Logger.info("Tile at %s contains: %s" % [grid_position, item.name], "StellarGridUI")
		
		# Show buff info if available
		if buff_visual_manager:
			var buff_info = buff_visual_manager.get_buff_info_for_tile(tile)
			Logger.info("Buff info: %s" % buff_info, "StellarGridUI")
	else:
		Logger.debug("No item selected and tile is empty", "StellarGridUI")

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
			Logger.info("Removed %s from position %s" % [removed_item.name, grid_position], "StellarGridUI")
			# Removed duplicate add_item_to_inventory call
			update_grid_display()
			update_inventory_display()
			show_removal_feedback(grid_position)
		else:
			Logger.warning("Failed to remove item from position %s" % grid_position, "StellarGridUI")
	else:
		Logger.debug("No item to remove at position %s" % grid_position, "StellarGridUI")

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
	if existing_indicator:
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
		
		# Animate pulsing
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
	Logger.info("Selected item for placement: %s" % item.name, "StellarGridUI")

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
		Logger.warning("Grid position %s is out of bounds for UI buttons" % grid_position, "StellarGridUI")
		return
	
	var button = grid_tile_buttons[grid_position.x][grid_position.y]
	
	if tile == null or button == null:
		return
	
	if tile.is_occupied():
		var item = tile.get_item()
		button.text = item.name
		button.modulate = tile.get_display_color()  # Use the new color system
	else:
		button.text = "Empty"
		button.modulate = Color.WHITE
	
	if tile.is_highlighted:
		button.modulate = Color.YELLOW

func update_production_display(resources_generated: Dictionary):
	"""Update the production display with generated resources"""
	if not production_display:
		Logger.warning("Production display is null, cannot update", "StellarGridUI")
		return
	
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
	if not grid_info_label:
		Logger.warning("Grid info label is null, cannot update", "StellarGridUI")
		return
	
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
	"""Handle input for drag and drop system and keyboard shortcuts"""
	if event is InputEventKey and event.pressed:
		# Toggle buff visuals with 'B' key
		if event.keycode == KEY_B:
			_on_buff_toggle_pressed()
			Logger.info("Buff visuals toggled via keyboard", "StellarGridUI")
	
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
	tutorial_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	tutorial_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	tutorial_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_panel.add_child(tutorial_text)
	
	var close_button = Button.new()
	close_button.text = "Got it!"
	close_button.anchor_top = 0.8
	close_button.anchor_bottom = 0.9
	close_button.anchor_left = 0.4
	close_button.anchor_right = 0.6
	close_button.pressed.connect(func(): 
		tutorial_overlay.queue_free()
		PlayerData.set_tutorial_completed("stellar_grid", true)
	)
	tutorial_panel.add_child(close_button) 

func setup_close_button():
	"""Setup the close button functionality"""
	var close_button = $MainContainer/Header/CloseButton
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
		Logger.info("Close button connected", "StellarGridUI")
	else:
		Logger.error("Close button not found", "StellarGridUI")

func _on_close_button_pressed():
	"""Handle close button press"""
	Logger.info("Close button pressed, hiding stellar grid", "StellarGridUI")
	visible = false 
