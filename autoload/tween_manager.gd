extends Node

# Global tween manager to help prevent "Target object freed before starting" errors
var active_tweens: Array[Tween] = []

func _ready():
	# Connect to scene tree changes to clean up tweens when scenes change
	get_tree().node_removed.connect(_on_node_removed)

func _on_node_removed(node: Node):
	"""Clean up tweens when nodes are removed from the scene tree"""
	_cleanup_tweens_for_node(node)

func _cleanup_tweens_for_node(node: Node):
	"""Remove any tweens that were targeting the removed node"""
	var tweens_to_remove: Array[int] = []
	
	for i in range(active_tweens.size()):
		var tween = active_tweens[i]
		if not tween or not tween.is_valid():
			tweens_to_remove.append(i)
			continue
			
		# Check if this tween is targeting the removed node
		# Note: This is a simplified check - in practice, you'd need to track target objects
		# For now, we'll just clean up invalid tweens
		if not tween.is_valid():
			tweens_to_remove.append(i)
	
	# Remove tweens in reverse order to maintain indices
	for i in range(tweens_to_remove.size() - 1, -1, -1):
		var index = tweens_to_remove[i]
		if index < active_tweens.size():
			var tween = active_tweens[index]
			if tween and tween.is_valid():
				tween.kill()
			active_tweens.remove_at(index)

func register_tween(tween: Tween):
	"""Register a tween for global management"""
	if tween and tween.is_valid():
		active_tweens.append(tween)

func cleanup_all_tweens():
	"""Clean up all active tweens"""
	for tween in active_tweens:
		if tween and tween.is_valid():
			tween.kill()
	active_tweens.clear()

func get_active_tween_count() -> int:
	"""Get the number of active tweens"""
	return active_tweens.size()

func print_tween_status():
	"""Print status of all active tweens for debugging"""
	print("Active tweens: ", active_tweens.size())
	for i in range(active_tweens.size()):
		var tween = active_tweens[i]
		if tween and tween.is_valid():
			print("Tween ", i, ": valid")
		else:
			print("Tween ", i, ": invalid") 