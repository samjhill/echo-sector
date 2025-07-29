extends Node
class_name TestRunnerScript

# Test runner script that can be executed to run all tests
# Usage: Run this script in Godot to execute all tests

func _ready():
	print("🧪 Starting Echo Sector Test Suite...")
	
	# Load the test runner class
	var test_runner_script = load("res://tests/test_runner.gd")
	if test_runner_script == null:
		print("❌ Error: Could not load test_runner.gd")
		get_tree().quit(1)
		return
	
	# Create test runner instance
	var test_runner = test_runner_script.new()
	add_child(test_runner)
	
	# The test runner will automatically run all tests and exit
	# when complete

# Alternative method to run tests programmatically
func run_tests():
	var test_runner_script = load("res://tests/test_runner.gd")
	if test_runner_script == null:
		print("❌ Error: Could not load test_runner.gd")
		return
	
	var test_runner = test_runner_script.new()
	test_runner.run_all_tests() 