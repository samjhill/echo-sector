extends Node

@export var duration: float = 20.0
@export var exit_gate_scene: PackedScene
@export var player: NodePath
var time_elapsed := 0.0
var running := true

func _ready():
	time_elapsed = 0.0
	running = true
	print("Abyssal zone started.")
	$GameIntroLabel.text = "Survive for " + str(duration) + " seconds"
	$HideLabelTimer.start()

func _on_HideLabelTimer_timeout():
	$GameIntroLabel.visible = false
	
func _process(delta):
	if not running:
		return

	time_elapsed += delta

	if time_elapsed >= duration:
		spawn_exit_gate()
		running = false

func spawn_exit_gate():
	print("Spawning exit gate...")

	if exit_gate_scene:
		var gate = exit_gate_scene.instantiate()

		var player_node = get_node_or_null(player)
		if player_node:
			var offset = Vector2(200, 0)
			gate.global_position = player_node.global_position + offset
		else:
			gate.global_position = Vector2(600, 300)

		get_tree().current_scene.add_child(gate)
		print("Exit gate added to scene at:", gate.global_position)
