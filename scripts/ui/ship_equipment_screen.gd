extends Control

@export var player: Node

var changing_slot_type = ""
var changing_slot_index = -1

func _ready():
	if not player:
		player = get_tree().get_first_node_in_group("players")
	if player:
		populate_equipment_screen()
	
	# Connect close button
	$MainContainer/Header/CloseButton.pressed.connect(_on_close_button_pressed)
	
	# Connect change buttons for weapon slots
	for i in range(2):
		var slot = $MainContainer/EquipmentContainer/WeaponSection/WeaponSlots.get_child(i)
		slot.get_child(0).get_node("Button").pressed.connect(_on_change_button_pressed.bind("weapon", i))
	
	# Connect change buttons for engine slots
	for i in range(2):
		var slot_name = "EngineSlot" + str(i+1) if i > 0 else "EngineSlot"
		var slot = $MainContainer/EquipmentContainer/EngineSection/EngineSlots.get_node(slot_name)
		slot.get_child(0).get_node("Button").pressed.connect(_on_change_button_pressed.bind("engine", i))

func _on_close_button_pressed():
	visible = false

func _check_and_show_equipment_notification():
	"""Check if equipment is missing and show a helpful notification"""
	var has_weapon = false
	var has_engine = false
	
	var equipped_weapons = PlayerData.get_equipped_weapons()
	for weapon in equipped_weapons:
		if weapon != null:
			has_weapon = true
			break
	
	var equipped_engines = PlayerData.get_equipped_engines()
	for engine in equipped_engines:
		if engine != null:
			has_engine = true
			break
	
	# If missing equipment, show notification
	if not has_weapon or not has_engine:
		_show_equipment_notification(not has_weapon, not has_engine)

func _show_equipment_notification(missing_weapon: bool, missing_engine: bool):
	"""Show a notification about missing equipment"""
	var message = ""
	if missing_weapon and missing_engine:
		message = "⚠️ You need to equip at least one weapon and one engine to launch!"
	elif missing_weapon:
		message = "⚠️ You need to equip at least one weapon to launch!"
	elif missing_engine:
		message = "⚠️ You need to equip at least one engine to launch!"
	
	if message != "":
		Logger.info("Showing equipment notification: %s" % message, "ShipEquipmentScreen")
		# TODO: In the future, we could add a proper notification UI here
		# For now, we'll just log it and could add a visual notification later

func populate_equipment_screen(show_missing_equipment_notification: bool = false):
	"""Populate the equipment screen with current equipment"""
	Logger.info("Populating equipment screen", "ShipEquipmentScreen")
	
	# Check if equipment is missing and show notification
	if show_missing_equipment_notification:
		_check_and_show_equipment_notification()
	# Populate weapon slots (support 2 slots)
	var equipped_weapons = PlayerData.get_equipped_weapons()
	Logger.debug("Equipped weapons: %d" % equipped_weapons.size(), "ShipEquipmentScreen")
	for i in range(2):
		var slot = $MainContainer/EquipmentContainer/WeaponSection/WeaponSlots.get_child(i)
		var container = slot.get_child(0)
		# Always reset to empty first
		container.get_node("TextureRect").texture = null
		container.get_node("Slot" + str(i+1) + "Info/Label").text = "Weapon Slot " + str(i+1)
		container.get_node("Slot" + str(i+1) + "Info/Slot" + str(i+1) + "Description").text = "Empty Slot"
		if i < equipped_weapons.size() and equipped_weapons[i] != null:
			var weapon = equipped_weapons[i]
			if weapon.icon:
				container.get_node("TextureRect").texture = weapon.icon
			container.get_node("Slot" + str(i+1) + "Info/Label").text = weapon.name
			container.get_node("Slot" + str(i+1) + "Info/Slot" + str(i+1) + "Description").text = weapon.description
			Logger.debug("Updated weapon slot %d with %s" % [i, weapon.name], "ShipEquipmentScreen")
	
	# Populate engine slots (support 2 slots)
	var equipped_engines = PlayerData.get_equipped_engines()
	Logger.debug("Equipped engines: %d" % equipped_engines.size(), "ShipEquipmentScreen")
	for i in range(2):
		var slot_name = "EngineSlot" + str(i+1) if i > 0 else "EngineSlot"
		var slot = $MainContainer/EquipmentContainer/EngineSection/EngineSlots.get_node(slot_name)
		var container = slot.get_child(0)
		# Always reset to empty first
		container.get_node("TextureRect").texture = null
		
		# Fix the node paths for engine slots
		var info_node_name = "EngineSlot" + str(i+1) + "Info" if i > 0 else "EngineSlotInfo"
		var description_node_name = "EngineSlot" + str(i+1) + "Description" if i > 0 else "EngineSlotDescription"
		
		container.get_node(info_node_name + "/Label").text = "Engine Slot " + str(i+1)
		container.get_node(info_node_name + "/" + description_node_name).text = "Empty Slot"
		
		if i < equipped_engines.size() and equipped_engines[i] != null:
			var engine = equipped_engines[i]
			if engine.icon:
				container.get_node("TextureRect").texture = engine.icon
			container.get_node(info_node_name + "/Label").text = engine.name
			container.get_node(info_node_name + "/" + description_node_name).text = engine.description
			Logger.debug("Updated engine slot %d with %s" % [i, engine.name], "ShipEquipmentScreen")

func _on_change_button_pressed(slot_type: String, slot_index: int):
	changing_slot_type = slot_type
	changing_slot_index = slot_index
	
	# Create a better popup with proper styling and positioning
	var popup = PopupMenu.new()
	popup.name = "EquipPopup"
	
	# Style the popup for better visibility and touch interaction
	popup.add_theme_font_size_override("font_size", 20)  # Larger font for touch
	
	# Add available items of the correct type
	var item_index = 0
	var available_items = []
	Logger.debug("Inventory size: %d" % PlayerData.inventory.size(), "ShipEquipmentScreen")
	for item in PlayerData.inventory:
		if item == null:
			Logger.warning("Found null item in inventory at index %d" % item_index, "ShipEquipmentScreen")
			continue
		if item.slot_type == slot_type:
			Logger.debug("Adding item to popup: %s of type %s" % [item.name, item.slot_type], "ShipEquipmentScreen")
			popup.add_item(item.name, item_index)
			available_items.append(item)
			item_index += 1
	
	# Add a "Cancel" option at the end
	popup.add_separator()
	popup.add_item("Cancel", -1)
	
	popup.connect("id_pressed", Callable(self, "_on_equip_item_selected").bind(popup, available_items))
	add_child(popup)
	
	popup.popup_centered()

func _on_equip_item_selected(id: int, popup: PopupMenu, available_items: Array):
	"""Handle equipment item selection"""
	var slot_type = changing_slot_type
	var slot_index = changing_slot_index
	
	Logger.debug("Selected item ID: %d from %d available items" % [id, available_items.size()], "ShipEquipmentScreen")
	
	# Handle cancel
	if id == -1:
		popup.queue_free()
		return
	
	if id >= 0 and id < available_items.size():
		var selected_item = available_items[id]
		if selected_item != null:
			# Use proper equipment management
			if slot_type == "weapon":
				var equipped_weapons = PlayerData.get_equipped_weapons()
				while equipped_weapons.size() <= slot_index:
					equipped_weapons.append(null)
				equipped_weapons[slot_index] = selected_item
				PlayerData.equipped_components["weapon"] = equipped_weapons
			elif slot_type == "engine":
				var equipped_engines = PlayerData.get_equipped_engines()
				while equipped_engines.size() <= slot_index:
					equipped_engines.append(null)
				equipped_engines[slot_index] = selected_item
				PlayerData.equipped_components["engine"] = equipped_engines
			
			Logger.info("Equipped %s in %s slot %d" % [selected_item.name, slot_type, slot_index], "ShipEquipmentScreen")
			PlayerData.save_game()
			populate_equipment_screen()
		else:
			Logger.error("Selected item is null", "ShipEquipmentScreen")
	else:
		Logger.error("Invalid item ID: %d from %d available items" % [id, available_items.size()], "ShipEquipmentScreen")
	
	popup.queue_free()
