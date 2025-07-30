# GameTutorial.gd
# Tutorial system for the main game - guides new players on enemy targeting
extends CanvasLayer
class_name GameTutorial

signal tutorial_completed

enum TutorialStep {
	WELCOME,
	ENEMY_HIGHLIGHT,
	WAIT_FOR_TAP,
	COMPLETE
}

@onready var tutorial_overlay: ColorRect
@onready var tutorial_panel: Panel
@onready var tutorial_text: RichTextLabel
@onready var got_it_button: Button

var current_step: TutorialStep = TutorialStep.WELCOME
var tutorial_data: Dictionary = {}
var highlighted_enemy: Node2D = null
var tutorial_active: bool = false

func _ready():
	setup_tutorial_data()
	setup_tutorial_ui()
	add_to_group("game_tutorial")

func setup_tutorial_data():
	"""Setup tutorial dialog and step information"""
	tutorial_data = {
		TutorialStep.WELCOME: {
			"title": "Welcome to Echo Sector!",
			"text": "Tap on enemies to lock on and automatically fire at them.\n\nLet's practice with the first enemy that appears!",
			"button_text": "Got it!"
		},
		TutorialStep.ENEMY_HIGHLIGHT: {
			"title": "Enemy Detected!",
			"text": "This enemy is highlighted. Tap on it to lock on and start firing!",
			"button_text": "I understand"
		},
		TutorialStep.WAIT_FOR_TAP: {
			"title": "Great!",
			"text": "You've locked on to the enemy! Your ship will automatically orbit and fire.\n\nTry tapping on different enemies to switch targets.",
			"button_text": "Continue"
		},
		TutorialStep.COMPLETE: {
			"title": "Tutorial Complete!",
			"text": "You're ready to survive the Echo Sector!\n\nSurvive for 30 seconds and find the exit portal to win.",
			"button_text": "Start Playing"
		}
	}

func setup_tutorial_ui():
	"""Setup the tutorial UI elements"""
	# Create tutorial overlay
	tutorial_overlay = ColorRect.new()
	tutorial_overlay.color = Color(0, 0, 0, 0.7)
	tutorial_overlay.anchor_right = 1.0
	tutorial_overlay.anchor_bottom = 1.0
	tutorial_overlay.layout_mode = 1  # Use anchors
	tutorial_overlay.visible = false
	add_child(tutorial_overlay)
	
	# Create tutorial panel
	tutorial_panel = Panel.new()
	tutorial_panel.anchor_left = 0.1
	tutorial_panel.anchor_right = 0.9
	tutorial_panel.anchor_top = 0.3
	tutorial_panel.anchor_bottom = 0.7
	tutorial_panel.layout_mode = 1  # Set to use anchors
	tutorial_overlay.add_child(tutorial_panel)
	
	# Create tutorial text
	tutorial_text = RichTextLabel.new()
	tutorial_text.anchor_left = 0.1
	tutorial_text.anchor_right = 0.9
	tutorial_text.anchor_top = 0.1
	tutorial_text.anchor_bottom = 0.7
	tutorial_text.layout_mode = 1  # Set to use anchors
	tutorial_text.bbcode_enabled = true  # Enable BBCode parsing
	tutorial_text.fit_content = true  # Auto-fit content
	tutorial_text.add_theme_font_size_override("normal_font_size", 18)
	tutorial_panel.add_child(tutorial_text)
	
	# Create got it button
	got_it_button = Button.new()
	got_it_button.anchor_left = 0.3
	got_it_button.anchor_right = 0.7
	got_it_button.anchor_top = 0.8
	got_it_button.anchor_bottom = 0.9
	got_it_button.layout_mode = 1  # Set to use anchors
	got_it_button.text = "Got it!"
	got_it_button.add_theme_font_size_override("font_size", 16)
	got_it_button.pressed.connect(_on_got_it_pressed)
	tutorial_panel.add_child(got_it_button)

func start_tutorial():
	"""Start the tutorial sequence"""
	if tutorial_active:
		return
		
	tutorial_active = true
	current_step = TutorialStep.WELCOME
	show_tutorial_overlay()
	display_current_step()
	Logger.info("Game tutorial started", "GameTutorial")

func show_tutorial_overlay():
	"""Show the tutorial overlay"""
	tutorial_overlay.visible = true

func hide_tutorial_overlay():
	"""Hide the tutorial overlay"""
	tutorial_overlay.visible = false

func display_current_step():
	"""Display the current tutorial step"""
	var step_data = tutorial_data[current_step]
	
	# Update text
	var full_text = "[center][b]%s[/b][/center]\n\n%s" % [
		step_data.get("title", ""),
		step_data.get("text", "")
	]
	tutorial_text.text = full_text
	
	# Update button
	got_it_button.text = step_data.get("button_text", "Continue")
	
	Logger.info("Displaying tutorial step: %s" % current_step, "GameTutorial")

func highlight_enemy(enemy: Node2D):
	"""Highlight an enemy for the tutorial"""
	if not tutorial_active or current_step != TutorialStep.ENEMY_HIGHLIGHT:
		return
		
	highlighted_enemy = enemy
	
	# Create a pulsing highlight effect
	var highlight_tween = create_tween()
	highlight_tween.set_loops()
	highlight_tween.tween_property(enemy, "modulate", Color.YELLOW, 0.5)
	highlight_tween.tween_property(enemy, "modulate", Color.WHITE, 0.5)
	
	Logger.info("Enemy highlighted for tutorial: %s" % enemy.name, "GameTutorial")

func on_enemy_tapped(enemy: Node2D):
	"""Handle when an enemy is tapped during tutorial"""
	if not tutorial_active:
		return
		
	if current_step == TutorialStep.WAIT_FOR_TAP:
		# Player successfully tapped an enemy
		Logger.info("Enemy tapped during tutorial: %s, progressing to next step", "GameTutorial")
		next_step()
	elif current_step == TutorialStep.ENEMY_HIGHLIGHT:
		# Enemy was tapped during highlight phase, also progress
		Logger.info("Enemy tapped during highlight phase: %s, progressing to next step", "GameTutorial")
		next_step()

func on_enemy_destroyed(enemy: Node2D):
	"""Handle when an enemy is destroyed during tutorial"""
	if not tutorial_active:
		return
		
	if current_step == TutorialStep.WAIT_FOR_TAP or current_step == TutorialStep.ENEMY_HIGHLIGHT:
		# Enemy was destroyed, progress tutorial
		Logger.info("Enemy destroyed during tutorial: %s, progressing to next step", "GameTutorial")
		next_step()

func _on_got_it_pressed():
	"""Handle got it button press"""
	next_step()

func next_step():
	"""Move to the next tutorial step"""
	Logger.info("Tutorial step progression: %s -> %s" % [current_step, current_step + 1], "GameTutorial")
	match current_step:
		TutorialStep.WELCOME:
			current_step = TutorialStep.ENEMY_HIGHLIGHT
			hide_tutorial_overlay()
			# Spawn first enemy for tutorial
			spawn_tutorial_enemy()
			Logger.info("Spawning tutorial enemy", "GameTutorial")
		TutorialStep.ENEMY_HIGHLIGHT:
			current_step = TutorialStep.WAIT_FOR_TAP
			display_current_step()
		TutorialStep.WAIT_FOR_TAP:
			current_step = TutorialStep.COMPLETE
			display_current_step()
			# Auto-complete tutorial after 3 seconds
			await get_tree().create_timer(3.0).timeout
			if current_step == TutorialStep.COMPLETE:
				Logger.info("Auto-completing tutorial after delay", "GameTutorial")
				complete_tutorial()
		TutorialStep.COMPLETE:
			complete_tutorial()

func spawn_tutorial_enemy():
	"""Spawn the first enemy for the tutorial"""
	var main_game = get_parent()
	if main_game and main_game.has_method("_on_spawn_enemy"):
		main_game._on_spawn_enemy()
		Logger.info("Tutorial enemy spawned", "GameTutorial")

func complete_tutorial():
	"""Complete the tutorial"""
	Logger.info("Completing tutorial, emitting signal", "GameTutorial")
	hide_tutorial_overlay()
	tutorial_active = false
	
	# Remove enemy highlight
	if highlighted_enemy:
		highlighted_enemy.modulate = Color.WHITE
		highlighted_enemy = null
	
	# Save tutorial completion
	PlayerData.set_tutorial_completed("game_tutorial", true)
	Logger.info("Tutorial completion saved to PlayerData", "GameTutorial")
	
	tutorial_completed.emit()
	Logger.info("Game tutorial completed and signal emitted", "GameTutorial")

func is_tutorial_completed() -> bool:
	"""Check if the tutorial has been completed"""
	return PlayerData.get_tutorial_completed("game_tutorial", false)

func should_show_tutorial() -> bool:
	"""Check if tutorial should be shown"""
	var completed = is_tutorial_completed()
	Logger.info("Tutorial completion check: completed=%s, should_show=%s" % [completed, not completed], "GameTutorial")
	return not completed 
