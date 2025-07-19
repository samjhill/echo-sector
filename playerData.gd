extends Node

var credits: int = 0
var unlocked_ships: Array[StringName] = []
var inventory: Array = []

const SAVE_FILE_PATH := "user://save_data.json"

func _ready():
	var test_item = {
		"name": "Plasma Core",
		"description": "Used in advanced weaponry",
		"icon": preload("res://items/plasma-core.png")
	}
	inventory.append(test_item)
	
func save_game():
	var data = {
		"credits": credits,
		"unlocked_ships": unlocked_ships
	}

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found.")
		return

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var result = JSON.parse_string(content)
	if result is Dictionary:
		credits = result.get("credits", 0)
		#unlocked_ships = result.get("unlocked_ships", [])
