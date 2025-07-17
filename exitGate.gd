extends Area2D

var armed := false

func _ready():
	print("Gate _ready() at:", global_position)
	armed = false
	$CollisionShape2D.disabled = true

	await get_tree().create_timer(1.0).timeout

	$CollisionShape2D.disabled = false
	connect("body_entered", Callable(self, "_on_body_entered"))
	armed = true
	print("Gate armed!")

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
