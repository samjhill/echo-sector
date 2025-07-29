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

func populate_equipment_screen():
	print("Populating equipment screen...")
	# Populate weapon slots (support 2 slots)
	var equipped_weapons = PlayerData.equipped_components["weapon"] if PlayerData.equipped_components.has("weapon") else []
	print("Equipped weapons:", equipped_weapons.size())
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
			print("Updated weapon slot", i, "with", weapon.name)
	
	# Populate engine slots (support 2 slots)
	var equipped_engines = PlayerData.equipped_components["engine"] if PlayerData.equipped_components.has("engine") else []
	print("Equipped engines:", equipped_engines.size())
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
			print("Updated engine slot", i, "with", engine.name)

func _on_change_button_pressed(slot_type: String, slot_index: int):
	changing_slot_type = slot_type
	changing_slot_index = slot_index
	# Show a simple selection dialog using PopupMenu
	var popup = PopupMenu.new()
	popup.name = "EquipPopup"
	# Add available items of the correct type
	var item_index = 0
	print("Inventory size:", PlayerData.inventory.size())
	for item in PlayerData.inventory:
		if item == null:
			print("Warning: Found null item in inventory at index", item_index)
			continue
		if item.slot_type == slot_type:
			print("Adding item to popup:", item.name, "of type", item.slot_type)
			popup.add_item(item.name, item_index)
			item_index += 1
	popup.connect("id_pressed", Callable(self, "_on_equip_item_selected").bind(popup))
	add_child(popup)
	# Show the popup at a default position
	popup.popup()

func _on_equip_item_selected(id: int, popup: PopupMenu):
	var slot_type = changing_slot_type
	var slot_index = changing_slot_index
	var items = []
	for item in PlayerData.inventory:
		if item.slot_type == slot_type:
			items.append(item)
	print("Selected item ID:", id, "from", items.size(), "available items")
	if id >= 0 and id < items.size():
		var selected_item = items[id]
		if selected_item != null:
			var equipped = PlayerData.equipped_components[slot_type] if PlayerData.equipped_components.has(slot_type) else []
			# Ensure the array is large enough
			while equipped.size() <= slot_index:
				equipped.append(null)
			equipped[slot_index] = selected_item
			PlayerData.equipped_components[slot_type] = equipped
			print("Equipped", selected_item.name, "in", slot_type, "slot", slot_index)
			PlayerData.save_game()
			populate_equipment_screen()
		else:
			print("Error: Selected item is null")
	else:
		print("Error: Invalid item ID:", id, "from", items.size(), "available items")
	popup.queue_free()
