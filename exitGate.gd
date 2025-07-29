extends Area2D

var armed := false
var spin_speed := 1.0  # radians per second
var glow_timer := 0.0
var glow_duration := 2.0

func _ready():
	print("Gate _ready() at:", global_position)
	armed = false
	$CollisionShape2D.disabled = true

	await get_tree().create_timer(1.0).timeout

	$CollisionShape2D.disabled = false
	connect("body_entered", Callable(self, "_on_body_entered"))
	armed = true
	print("Gate armed!")
	
	# Start visual effects
	_start_visual_effects()

func _process(delta):
	# Update spinning effect
	if $PortalSprite:
		$PortalSprite.rotation += spin_speed * delta
	
	# Update glowing effect
	if $GlowSprite:
		glow_timer += delta
		var glow_progress = (glow_timer / glow_duration) * 2 * PI
		var alpha = 0.5 + 0.3 * sin(glow_progress)
		$GlowSprite.modulate = Color(1, 1, 1, alpha)

func _start_visual_effects():
	# Start particle effects
	var particles = $Particles
	if particles:
		particles.emitting = true

func _on_body_entered(body):
	print("Gate body entered:", body.name)
	if not armed:
		print("Gate triggered too early — ignoring")
		return

	if body.is_in_group("players"):
		print("Gate triggered!")
		var reward = 25
		PlayerData.credits += reward
		PlayerData.save_game()

		var win_screen = preload("res://win_screen.tscn").instantiate()
		win_screen.credits_earned = reward

		get_tree().root.add_child(win_screen)
		get_tree().current_scene.queue_free()
	else:
		print("body is not in group player")
		print("Groups of body:", body.get_groups())
