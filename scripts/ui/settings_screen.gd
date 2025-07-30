# SettingsScreen.gd
# Settings menu for the game
extends Control
class_name SettingsScreen

# UI elements
var back_button: Button
var clear_save_button: Button
var version_label: Label
var build_label: Label

# Confirmation dialog
var confirmation_dialog: AcceptDialog

func _ready():
	Logger.info("Initializing Settings Screen", "SettingsScreen")
	setup_ui_elements()
	setup_confirmation_dialog()
	update_display_info()

func setup_ui_elements():
	"""Setup UI element references and connections"""
	back_button = $MainContainer/Header/BackButton
	clear_save_button = $MainContainer/Content/ContentVBox/GameSection/ClearSaveButton
	version_label = $MainContainer/Content/ContentVBox/InfoSection/VersionLabel
	build_label = $MainContainer/Content/ContentVBox/InfoSection/BuildLabel
	
	# Connect button signals
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	
	if clear_save_button:
		clear_save_button.pressed.connect(_on_clear_save_button_pressed)
	
	Logger.info("Settings UI elements setup complete", "SettingsScreen")

func setup_confirmation_dialog():
	"""Setup the confirmation dialog for clearing save data"""
	confirmation_dialog = AcceptDialog.new()
	confirmation_dialog.title = "Confirm Clear Save Data"
	confirmation_dialog.dialog_text = "Are you sure you want to permanently delete all saved game data?\n\nThis will remove:\n• All inventory items\n• Credits and scrap\n• Stellar Grid layout\n• Equipment loadout\n\nThis action cannot be undone."
	confirmation_dialog.ok_button_text = "Clear All Data"
	confirmation_dialog.add_cancel_button("Cancel")
	
	# Style the dialog
	confirmation_dialog.add_theme_color_override("font_color", Color.WHITE)
	confirmation_dialog.add_theme_color_override("font_hover_color", Color.YELLOW)
	
	# Connect signals
	confirmation_dialog.confirmed.connect(_on_clear_save_confirmed)
	confirmation_dialog.canceled.connect(_on_clear_save_canceled)
	
	add_child(confirmation_dialog)
	Logger.info("Confirmation dialog setup complete", "SettingsScreen")

func update_display_info():
	"""Update the display information with current game data"""
	if version_label:
		version_label.text = "Version: 1.0.0"
	
	if build_label:
		# Get build version from BuildVersion autoload if available
		if BuildVersion:
			build_label.text = "Build: %s - %s" % [BuildVersion.BUILD_VERSION, BuildVersion.BUILD_TIMESTAMP]
		else:
			build_label.text = "Build: Development"
	
	Logger.info("Display info updated", "SettingsScreen")

func _on_back_button_pressed():
	"""Handle back button press"""
	Logger.info("Back button pressed, hiding settings", "SettingsScreen")
	visible = false

func _on_clear_save_button_pressed():
	"""Handle clear save button press - show confirmation dialog"""
	Logger.info("Clear save button pressed, showing confirmation dialog", "SettingsScreen")
	confirmation_dialog.popup_centered()

func _on_clear_save_confirmed():
	"""Handle confirmation of clearing save data"""
	Logger.info("Clear save confirmed, deleting save files", "SettingsScreen")
	
	# Check save files before clearing
	check_save_files()
	
	clear_all_save_files()
	
	# Check save files after clearing
	check_save_files()
	
	show_clear_success_message()

func _on_clear_save_canceled():
	"""Handle cancellation of clearing save data"""
	Logger.info("Clear save canceled", "SettingsScreen")

func clear_all_save_files():
	"""Clear all save files from the user directory"""
	var save_files = [
		"user://save_data.json",
		"user://stellar_grid_save.json"
	]
	
	var files_deleted = 0
	
	for file_path in save_files:
		if FileAccess.file_exists(file_path):
			Logger.info("Attempting to delete save file: %s" % file_path, "SettingsScreen")
			
			# Try using DirAccess to remove the file
			var dir = DirAccess.open("user://")
			if dir:
				var filename = file_path.get_file()
				var result = dir.remove(filename)
				if result == OK:
					Logger.info("Successfully deleted save file: %s" % file_path, "SettingsScreen")
					files_deleted += 1
				else:
					Logger.error("Failed to delete save file: %s (error: %d)" % [file_path, result], "SettingsScreen")
					# Try alternative method using FileAccess
					var file = FileAccess.open(file_path, FileAccess.WRITE)
					if file:
						file.close()
						Logger.info("Cleared save file content: %s" % file_path, "SettingsScreen")
						files_deleted += 1
			else:
				Logger.error("Failed to open user directory", "SettingsScreen")
		else:
			Logger.info("Save file does not exist: %s" % file_path, "SettingsScreen")
	
	# Verify files are actually deleted/cleared
	Logger.info("Verifying save file deletion...", "SettingsScreen")
	for file_path in save_files:
		if FileAccess.file_exists(file_path):
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				file.close()
				if content.strip_edges() == "":
					Logger.info("Save file is empty: %s" % file_path, "SettingsScreen")
				else:
					Logger.warning("Save file still has content: %s" % file_path, "SettingsScreen")
		else:
			Logger.info("Save file successfully deleted: %s" % file_path, "SettingsScreen")
	
	# Reset PlayerData to initial state
	if PlayerData:
		Logger.info("Resetting PlayerData to initial state", "SettingsScreen")
		PlayerData.credits = 50
		PlayerData.scrap = 25
		PlayerData.inventory.clear()
		PlayerData.equipped_components.clear()
		PlayerData.tutorial_completed.clear()
		
		# Force a fresh load to ensure starter items are added
		PlayerData.load_game()
		
		# Emit signals to update UI
		PlayerData.credits_changed.emit(PlayerData.credits)
		PlayerData.scrap_changed.emit(PlayerData.scrap)
		PlayerData.inventory_changed.emit()
		
		Logger.info("PlayerData reset complete. Credits: %d, Scrap: %d, Inventory size: %d" % [PlayerData.credits, PlayerData.scrap, PlayerData.inventory.size()], "SettingsScreen")
	
	Logger.info("Clear save operation completed. Files deleted: %d" % files_deleted, "SettingsScreen")

func show_clear_success_message():
	"""Show a success message after clearing save data"""
	var success_dialog = AcceptDialog.new()
	success_dialog.title = "Save Data Cleared"
	success_dialog.dialog_text = "All save data has been successfully cleared.\n\nThe game will now start fresh with default starter items."
	success_dialog.ok_button_text = "OK"
	
	# Style the dialog
	success_dialog.add_theme_color_override("font_color", Color.WHITE)
	success_dialog.add_theme_color_override("font_hover_color", Color.YELLOW)
	
	# Connect signal
	success_dialog.confirmed.connect(_on_success_dialog_closed)
	
	add_child(success_dialog)
	success_dialog.popup_centered()
	
	Logger.info("Success dialog shown", "SettingsScreen")

func _on_success_dialog_closed():
	"""Handle success dialog close"""
	Logger.info("Success dialog closed", "SettingsScreen")
	# Hide the settings screen and return to main menu
	visible = false

func check_save_files():
	"""Debug function to check the status of save files"""
	Logger.info("=== SAVE FILE STATUS CHECK ===", "SettingsScreen")
	
	var save_files = [
		"user://save_data.json",
		"user://stellar_grid_save.json"
	]
	
	for file_path in save_files:
		if FileAccess.file_exists(file_path):
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				file.close()
				Logger.info("File exists: %s (size: %d bytes)" % [file_path, content.length()], "SettingsScreen")
				if content.length() > 0:
					Logger.info("Content preview: %s" % content.substr(0, min(100, content.length())), "SettingsScreen")
				else:
					Logger.info("File is empty", "SettingsScreen")
			else:
				Logger.error("Cannot read file: %s" % file_path, "SettingsScreen")
		else:
			Logger.info("File does not exist: %s" % file_path, "SettingsScreen")
	
	Logger.info("=== END SAVE FILE STATUS ===", "SettingsScreen") 
