extends Node
class_name TestRunner

# Test configuration
var test_results = {}
var total_tests = 0
var passed_tests = 0
var failed_tests = 0

# Test suites
var test_suites = []

func _ready():
	print("🚀 Starting Echo Sector Test Suite...")
	run_all_tests()

func run_all_tests():
	# Initialize test suites
	test_suites = [
		PlayerDataTestSuite.new(),
		ResourceLoadingTestSuite.new(),
		EquipmentSystemTestSuite.new(),
		UITestSuite.new()
	]
	
	# Run all test suites
	for suite in test_suites:
		run_test_suite(suite)
	
	# Print final results
	print_results()

func run_test_suite(suite):
	print("\n📋 Running test suite: ", suite.get_class_name())
	
	# Get all test methods
	var test_methods = []
	for method in suite.get_method_list():
		if method.name.begins_with("test_"):
			test_methods.append(method.name)
	
	# Run each test
	for method_name in test_methods:
		run_single_test(suite, method_name)

func run_single_test(suite, method_name):
	total_tests += 1
	print("  🧪 Running: ", method_name)
	
	var start_time = Time.get_ticks_msec()
	var result = {}
	
	# Run the test
	suite.setup_test()
	var test_passed = false
	var error_message = ""
	
	try:
		suite.call(method_name)
		test_passed = true
	except:
		error_message = "Exception: " + str(suite.get_error())
		test_passed = false
	
	suite.teardown_test()
	
	var end_time = Time.get_ticks_msec()
	var duration = end_time - start_time
	
	# Record result
	result = {
		"passed": test_passed,
		"duration": duration,
		"error": error_message
	}
	
	test_results[method_name] = result
	
	if test_passed:
		passed_tests += 1
		print("    ✅ PASSED (", duration, "ms)")
	else:
		failed_tests += 1
		print("    ❌ FAILED (", duration, "ms): ", error_message)

func print_results():
	print("\n" + "="*50)
	print("📊 TEST RESULTS")
	print("="*50)
	print("Total Tests: ", total_tests)
	print("Passed: ", passed_tests)
	print("Failed: ", failed_tests)
	print("Success Rate: ", (float(passed_tests) / float(total_tests) * 100.0) if total_tests > 0 else 0, "%")
	
	if failed_tests > 0:
		print("\n❌ FAILED TESTS:")
		for test_name in test_results:
			var result = test_results[test_name]
			if not result.passed:
				print("  - ", test_name, ": ", result.error)
	
	print("="*50)
	
	# Exit with appropriate code
	if failed_tests > 0:
		get_tree().quit(1)  # Exit with error code
	else:
		get_tree().quit(0)  # Exit with success code

# Utility functions for tests
func assert_true(condition, message = ""):
	if not condition:
		push_error("Assertion failed: " + message)
		return false
	return true

func assert_false(condition, message = ""):
	if condition:
		push_error("Assertion failed: " + message)
		return false
	return true

func assert_equal(expected, actual, message = ""):
	if expected != actual:
		push_error("Assertion failed: Expected " + str(expected) + ", got " + str(actual) + ". " + message)
		return false
	return true

func assert_not_null(value, message = ""):
	if value == null:
		push_error("Assertion failed: Value is null. " + message)
		return false
	return true

func assert_null(value, message = ""):
	if value != null:
		push_error("Assertion failed: Value is not null. " + message)
		return false
	return true 