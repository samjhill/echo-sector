# GridTutorial.gd
# Tutorial system for the Stellar Grid onboarding experience
extends Control
class_name GridTutorial

signal tutorial_completed
signal step_completed(step_name: String)

enum TutorialStep {
	WELCOME,
	GRID_OVERVIEW,
	MODULE_PLACEMENT,
	ADJACENCY_BONUS,
	RESEARCH_INTEGRATION,
	PRODUCTION_CYCLE,
	COMPLETE
}

@onready var tutorial_overlay: ColorRect = $TutorialOverlay
@onready var dialog_panel: Panel = $DialogPanel
@onready var dialog_text: Label = $DialogPanel/DialogText
@onready var next_button: Button = $DialogPanel/NextButton
@onready var skip_button: Button = $DialogPanel/SkipButton

var current_step: TutorialStep = TutorialStep.WELCOME
var grid_manager: GridManager
var tutorial_data: Dictionary = {}

func _ready():
	setup_tutorial_data()
	connect_signals()
	start_tutorial()

func setup_tutorial_data():
	"""Setup tutorial dialog and step information"""
	tutorial_data = {
		TutorialStep.WELCOME: {
			"title": "Welcome to the Stellar Grid!",
			"text": "This is your space station's power and research hub. Modules placed here generate resources automatically and can unlock new technologies.",
			"highlight": null
		},
		TutorialStep.GRID_OVERVIEW: {
			"title": "Grid Overview",
			"text": "You start with a 3x3 grid. Each tile can hold one module. The grid will expand as you progress.",
			"highlight": "grid"
		},
		TutorialStep.MODULE_PLACEMENT: {
			"title": "Module Placement",
			"text": "You have 3 starter modules: Power Core (generates energy), Extractor (processes materials), and Research Lab (develops blueprints).",
			"highlight": "inventory"
		},
		TutorialStep.ADJACENCY_BONUS: {
			"title": "Adjacency Matters",
			"text": "Modules benefit from being near each other! The Extractor gets +20% output when next to a Power Core. Try placing them adjacent.",
			"highlight": "adjacency"
		},
		TutorialStep.RESEARCH_INTEGRATION: {
			"title": "Research Integration",
			"text": "Research Labs generate blueprint fragments over time. These will unlock new modules and technologies for your ship.",
			"highlight": "research"
		},
		TutorialStep.PRODUCTION_CYCLE: {
			"title": "Production Cycle",
			"text": "Modules produce resources every 5 seconds. Watch the production display to see your output. The more modules you place, the more you generate!",
			"highlight": "production"
		},
		TutorialStep.COMPLETE: {
			"title": "Tutorial Complete!",
			"text": "You're ready to expand your Stellar Grid! Unlock new tiles, discover advanced modules, and build the ultimate space station.",
			"highlight": null
		}
	}

func connect_signals():
	"""Connect tutorial UI signals"""
	next_button.pressed.connect(_on_next_button_pressed)
	skip_button.pressed.connect(_on_skip_button_pressed)

func start_tutorial():
	"""Start the tutorial sequence"""
	current_step = TutorialStep.WELCOME
	show_tutorial_overlay()
	show_current_step()

func show_tutorial_overlay():
	"""Show the tutorial overlay"""
	tutorial_overlay.visible = true
	dialog_panel.visible = true

func hide_tutorial_overlay():
	"""Hide the tutorial overlay"""
	tutorial_overlay.visible = false
	dialog_panel.visible = false

func show_current_step():
	"""Display the current tutorial step"""
	var step_data = tutorial_data[current_step]
	if step_data:
		dialog_text.text = step_data.text
		highlight_relevant_area(step_data.get("highlight"))

func highlight_relevant_area(area: String):
	"""Highlight the relevant UI area for the current step"""
	# Remove previous highlights
	remove_highlights()
	
	match area:
		"grid":
			highlight_grid()
		"inventory":
			highlight_inventory()
		"adjacency":
			highlight_adjacency_example()
		"research":
			highlight_research_info()
		"production":
			highlight_production_display()

func remove_highlights():
	"""Remove all tutorial highlights"""
	# This would be implemented to remove visual highlights
	pass

func highlight_grid():
	"""Highlight the grid area"""
	# Add visual highlight to grid
	pass

func highlight_inventory():
	"""Highlight the inventory area"""
	# Add visual highlight to inventory
	pass

func highlight_adjacency_example():
	"""Highlight adjacency example"""
	# Show example of adjacency bonus
	pass

func highlight_research_info():
	"""Highlight research information"""
	# Highlight research-related UI
	pass

func highlight_production_display():
	"""Highlight production display"""
	# Highlight production information
	pass

func _on_next_button_pressed():
	"""Handle next button press"""
	step_completed.emit(tutorial_data[current_step].get("title", ""))
	
	match current_step:
		TutorialStep.WELCOME:
			current_step = TutorialStep.GRID_OVERVIEW
		TutorialStep.GRID_OVERVIEW:
			current_step = TutorialStep.MODULE_PLACEMENT
		TutorialStep.MODULE_PLACEMENT:
			current_step = TutorialStep.ADJACENCY_BONUS
		TutorialStep.ADJACENCY_BONUS:
			current_step = TutorialStep.RESEARCH_INTEGRATION
		TutorialStep.RESEARCH_INTEGRATION:
			current_step = TutorialStep.PRODUCTION_CYCLE
		TutorialStep.PRODUCTION_CYCLE:
			current_step = TutorialStep.COMPLETE
		TutorialStep.COMPLETE:
			complete_tutorial()
			return
	
	show_current_step()

func _on_skip_button_pressed():
	"""Skip the tutorial"""
	complete_tutorial()

func complete_tutorial():
	"""Complete the tutorial"""
	hide_tutorial_overlay()
	tutorial_completed.emit()
	
	# Save tutorial completion
	PlayerData.set_tutorial_completed("stellar_grid", true)

func is_tutorial_completed() -> bool:
	"""Check if the tutorial has been completed"""
	return PlayerData.get_tutorial_completed("stellar_grid", false) 