extends TextureRect
class_name AnimatedBackground

# Animation settings
@export var animation_speed: float = 20.0  # pixels per second
@export var animation_delay: float = 0.0   # delay before starting animation
@export var pan_distance: float = 0.3      # how much of the image to pan (0.0 to 1.0)

# Animation state
var is_animating: bool = false
var start_position: Vector2
var target_position: Vector2
var animation_progress: float = 0.0
var delay_timer: float = 0.0

func _ready():
	# Set up the animation
	setup_animation()

func setup_animation():
	# Let the TextureRect handle scaling with stretch_mode=5 and expand_mode=1
	# We just need to handle the panning animation
	
	# Get the current position (should be 0,0 since TextureRect handles scaling)
	start_position = Vector2.ZERO
	
	# Calculate how much we can pan based on the texture size vs viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	var texture_size = texture.get_size() if texture else Vector2.ZERO
	
	# Calculate how much extra width we have for panning
	var scale_factor = viewport_size.y / texture_size.y  # Scale to fill height
	var scaled_width = texture_size.x * scale_factor
	var extra_width = scaled_width - viewport_size.x
	
	# Calculate pan distance
	var actual_pan_distance = extra_width * pan_distance
	
	# Set target position (move left to show right edge)
	target_position = Vector2(-actual_pan_distance, 0)
	
	# Start the animation after delay
	if animation_delay > 0.0:
		delay_timer = animation_delay
	else:
		start_animation()

func _process(delta):
	if delay_timer > 0.0:
		delay_timer -= delta
		if delay_timer <= 0.0:
			start_animation()
		return
	
	if is_animating:
		# Calculate animation progress
		var total_distance = (target_position - start_position).length()
		var current_distance = animation_speed * animation_progress
		
		# Update position based on progress
		var progress_ratio = current_distance / total_distance
		position = start_position.lerp(target_position, progress_ratio)
		
		# Update animation progress
		animation_progress += delta
		
		# Check if animation is complete
		if progress_ratio >= 1.0:
			# Reset to start position and continue the loop
			position = start_position
			animation_progress = 0.0

func start_animation():
	is_animating = true
	animation_progress = 0.0

func stop_animation():
	is_animating = false

func pause_animation():
	is_animating = false

func resume_animation():
	is_animating = true 