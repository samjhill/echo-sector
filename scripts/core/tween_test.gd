extends Node2D

# Simple test script to verify tween cleanup functionality
func _ready():
	print("Tween test script loaded")
	
	# Test creating and cleaning up tweens
	test_tween_cleanup()

func test_tween_cleanup():
	"""Test tween cleanup functionality"""
	print("Testing tween cleanup...")
	
	# Create a test node
	var test_node = Node2D.new()
	add_child(test_node)
	
	# Create a tween on the test node
	var tween = create_tween()
	tween.tween_property(test_node, "position", Vector2(100, 100), 1.0)
	
	# Register with tween manager
	TweenManager.register_tween(tween)
	
	print("Created tween, active count: ", TweenManager.get_active_tween_count())
	
	# Remove the test node (should trigger cleanup)
	test_node.queue_free()
	
	# Wait a frame for cleanup
	await get_tree().process_frame
	
	print("After node removal, active count: ", TweenManager.get_active_tween_count())
	
	# Clean up any remaining tweens
	TweenManager.cleanup_all_tweens()
	
	print("After cleanup, active count: ", TweenManager.get_active_tween_count()) 