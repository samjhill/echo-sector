# ErrorDisplay.gd
# On-screen error display system for mobile debugging
extends CanvasLayer
class_name ErrorDisplay

var error_panel: Panel
var error_label: RichTextLabel
var error_timer: Timer
var error_queue: Array[String] = []
var is_showing_error: bool = false

func _ready():
	setup_error_ui()
	error_timer = Timer.new()
	error_timer.wait_time = 3.0
	error_timer.one_shot = true
	error_timer.timeout.connect(_on_error_timeout)
	add_child(error_timer)

func setup_error_ui():
	"""Setup the error display UI"""
	# Create error panel
	error_panel = Panel.new()
	error_panel.anchor_left = 0.1
	error_panel.anchor_right = 0.9
	error_panel.anchor_top = 0.1
	error_panel.anchor_bottom = 0.3
	error_panel.visible = false
	error_panel.modulate.a = 0.9
	add_child(error_panel)
	
	# Create error label
	error_label = RichTextLabel.new()
	error_label.anchor_left = 0.05
	error_label.anchor_right = 0.95
	error_label.anchor_top = 0.05
	error_label.anchor_bottom = 0.95
	error_label.bbcode_enabled = true
	error_label.fit_content = true
	error_label.add_theme_font_size_override("normal_font_size", 14)
	error_panel.add_child(error_label)

func show_error(message: String, duration: float = 3.0):
	"""Show an error message on screen"""
	error_queue.append(message)
	if not is_showing_error:
		_show_next_error()

func _show_next_error():
	"""Show the next error in the queue"""
	if error_queue.size() == 0:
		is_showing_error = false
		return
	
	is_showing_error = true
	var message = error_queue.pop_front()
	
	# Format the error message
	var formatted_message = "[center][color=red][b]ERROR[/b][/color][/center]\n\n%s" % message
	error_label.text = formatted_message
	
	# Show the panel
	error_panel.visible = true
	
	# Set timer to hide
	error_timer.wait_time = 3.0
	error_timer.start()

func _on_error_timeout():
	"""Hide error panel and show next error"""
	error_panel.visible = false
	_show_next_error()

func show_warning(message: String, duration: float = 2.0):
	"""Show a warning message on screen"""
	var warning_message = "[WARNING] " + message
	error_queue.append(warning_message)
	if not is_showing_error:
		_show_next_error()

func show_info(message: String, duration: float = 2.0):
	"""Show an info message on screen"""
	var info_message = "[INFO] " + message
	error_queue.append(info_message)
	if not is_showing_error:
		_show_next_error() 