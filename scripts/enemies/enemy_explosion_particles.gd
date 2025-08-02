extends GPUParticles2D

var player_position: Vector2
var scrap_particles: Array[GPUParticles2D] = []

func _ready():
	# Find the player
	var player = get_tree().get_first_node_in_group("players")
	if player and is_instance_valid(player):
		player_position = player.global_position
	else:
		player_position = Vector2.ZERO
	
	# Start the main explosion particles
	emitting = true
	
	# Create scrap collection particles after a short delay
	await get_tree().create_timer(0.1).timeout
	_spawn_scrap_particles()
	
	# Wait for particles to finish, then free the node
	await get_tree().create_timer(lifetime + 0.5).timeout
	queue_free()

func _spawn_scrap_particles():
	# Create particles that move toward the player (scrap collection effect)
	for i in range(8):  # 8 scrap particles
		var scrap_particle = GPUParticles2D.new()
		scrap_particle.amount = 1
		scrap_particle.lifetime = 1.5
		scrap_particle.one_shot = true
		scrap_particle.emitting = false
		
		# Create material for scrap particles with direction toward player
		var scrap_material = ParticleProcessMaterial.new()
		scrap_material.emission_shape = 1
		scrap_material.emission_sphere_radius = 5.0
		scrap_material.particle_flag_disable_z = true
		scrap_material.gravity = Vector3(0, 0, 0)
		
		# Calculate direction toward player
		var direction_to_player = (player_position - global_position).normalized()
		scrap_material.direction = Vector3(direction_to_player.x, direction_to_player.y, 0)
		scrap_material.spread = 30.0  # Narrow spread toward player
		scrap_material.initial_velocity_min = 80.0
		scrap_material.initial_velocity_max = 120.0
		scrap_material.scale_min = 1.5
		scrap_material.scale_max = 2.5
		scrap_material.color_ramp = null
		
		scrap_particle.process_material = scrap_material
		scrap_particle.global_position = global_position
		var current_scene = get_tree().current_scene
		if current_scene and is_instance_valid(current_scene):
			current_scene.add_child(scrap_particle)
			
			# Start emitting
			scrap_particle.emitting = true
			
			# Store reference for cleanup
			scrap_particles.append(scrap_particle)
			
			# Clean up after animation
			await get_tree().create_timer(1.5).timeout
			if is_instance_valid(scrap_particle):
				scrap_particle.queue_free() 