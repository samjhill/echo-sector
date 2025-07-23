extends Control

@export var player: Node

func _ready():
	if not player:
		player = get_tree().get_first_node_in_group("players")
	if player:
		populate_equipment_screen()

func populate_equipment_screen():
	# Populate weapon slots
	for i in player.weapon_components.size():
		var weapon = player.weapon_components[i]
		var slot = $Panel/VBoxContainer/WeaponSlots.get_child(i)
		slot.get_node("TextureRect").texture = weapon.icon
		slot.get_node("Label").text = weapon.name

	# Populate engine slot
	var engine_slot = $Panel/VBoxContainer/EngineSlot
	engine_slot.get_node("TextureRect").texture = player.engine_component.icon
	engine_slot.get_node("Label").text = player.engine_component.name
