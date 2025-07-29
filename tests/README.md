# Echo Sector Testing Framework

This directory contains comprehensive automated tests for the Echo Sector game.

## 🧪 Test Structure

```
tests/
├── README.md                 # This file
├── test_runner.gd            # Main test runner
├── base_test_suite.gd        # Base test suite with common utilities
├── test_scene.tscn          # Test scene for running tests
├── run_tests.gd             # Script to run tests
├── unit/                    # Unit tests
│   ├── test_player_data.gd  # PlayerData autoload tests
│   ├── test_resource_loading.gd # Resource loading tests
│   └── test_equipment_system.gd # Equipment system tests
└── ui/                      # UI integration tests
    └── test_ui_integration.gd # UI and scene tests
```

## 🚀 Running Tests

### Method 1: Using the Test Scene
1. Open the test scene: `res://tests/test_scene.tscn`
2. Run the scene in Godot
3. Tests will execute automatically and show results in the console

### Method 2: Using the Test Runner Script
1. Open the test runner script: `res://tests/run_tests.gd`
2. Run the script in Godot
3. Tests will execute and show results

### Method 3: Command Line (if Godot is in PATH)
```bash
godot --headless --script res://tests/run_tests.gd
```

## 📋 Test Categories

### Unit Tests (`tests/unit/`)

#### PlayerData Tests (`test_player_data.gd`)
- ✅ Save/load functionality
- ✅ Initial game state
- ✅ Inventory management
- ✅ Equipment management
- ✅ Resource loading for weapons and engines
- ✅ Error handling for invalid resources
- ✅ Scrap management
- ✅ Corrupted save file handling
- ✅ Equipment serialization

#### Resource Loading Tests (`test_resource_loading.gd`)
- ✅ Loading of different resource types (.gd scripts, .tres files)
- ✅ Resource properties validation
- ✅ Resource type detection (Script vs Resource)
- ✅ Error handling for missing resources
- ✅ Resource instantiation patterns
- ✅ Resource path validation
- ✅ Inheritance hierarchy validation
- ✅ Resource serialization compatibility

#### Equipment System Tests (`test_equipment_system.gd`)
- ✅ Equipment screen initialization
- ✅ Inventory filtering by slot type
- ✅ Equipment slot management
- ✅ Equipment validation
- ✅ Equipment serialization
- ✅ Equipment slot limits
- ✅ Equipment removal
- ✅ Launch validation
- ✅ Equipment data integrity
- ✅ Equipment compatibility
- ✅ Error handling
- ✅ Performance testing

### UI Integration Tests (`tests/ui/`)

#### UI Integration Tests (`test_ui_integration.gd`)
- ✅ Scene loading validation
- ✅ Script path validation
- ✅ Texture path validation
- ✅ Autoload path validation
- ✅ Launch validation logic
- ✅ Equipment screen population
- ✅ Scene transition paths
- ✅ UI element accessibility
- ✅ Error handling in UI
- ✅ UI performance
- ✅ UI data consistency
- ✅ UI state management

## 🛠️ Test Utilities

### BaseTestSuite Class
The `BaseTestSuite` class provides common testing utilities:

- **Assertion methods**: `assert_true()`, `assert_false()`, `assert_equal()`, `assert_not_null()`, `assert_null()`
- **Test data creation**: `create_test_item()`, `create_test_weapon()`, `create_test_engine()`
- **File management**: `create_temp_save_file()`, `cleanup_temp_save_file()`
- **Setup/teardown**: `setup_test()`, `teardown_test()`

### Test Runner
The `TestRunner` class orchestrates all tests:

- **Test discovery**: Automatically finds all test methods (starting with `test_`)
- **Test execution**: Runs tests with timing and error reporting
- **Result reporting**: Provides detailed pass/fail statistics
- **Exit codes**: Returns appropriate exit codes for CI/CD integration

## 📊 Test Results

Tests provide detailed output including:

- ✅ **Passed tests** with timing information
- ❌ **Failed tests** with error messages
- 📊 **Summary statistics** (total, passed, failed, success rate)
- ⏱️ **Performance metrics** for timing-sensitive tests

## 🔧 Adding New Tests

### Creating a New Test Suite

1. Create a new test file in the appropriate directory:
   ```gdscript
   extends BaseTestSuite
   class_name YourTestSuite
   
   func setup_test():
       # Setup code here
       pass
   
   func teardown_test():
       # Cleanup code here
       pass
   
   func test_your_feature():
       # Your test code here
       assert_true(condition, "Description")
   ```

2. Add the test suite to the test runner in `test_runner.gd`:
   ```gdscript
   test_suites = [
       PlayerDataTestSuite.new(),
       ResourceLoadingTestSuite.new(),
       EquipmentSystemTestSuite.new(),
       UITestSuite.new(),
       YourTestSuite.new()  # Add your new suite
   ]
   ```

### Test Best Practices

1. **Isolation**: Each test should be independent and not rely on other tests
2. **Cleanup**: Always clean up test data in `teardown_test()`
3. **Descriptive names**: Use clear, descriptive test method names
4. **Assertions**: Use specific assertions with meaningful error messages
5. **Performance**: Keep tests fast and efficient
6. **Coverage**: Test both success and failure scenarios

## 🐛 Debugging Tests

### Common Issues

1. **Resource loading failures**: Check file paths and ensure resources exist
2. **Autoload errors**: Verify autoload paths in `project.godot`
3. **Scene loading failures**: Check scene file paths and dependencies
4. **Type errors**: Ensure proper type checking and casting

### Debugging Tips

1. **Add print statements**: Use `print()` for debugging test logic
2. **Check file paths**: Verify all resource paths are correct
3. **Test isolation**: Run individual test methods to isolate issues
4. **Console output**: Check the Godot console for detailed error messages

## 📈 Continuous Integration

The test framework is designed to work with CI/CD systems:

- **Exit codes**: Tests return appropriate exit codes (0 for success, 1 for failure)
- **Console output**: Detailed results are printed to console
- **Headless mode**: Tests can run without GUI using `--headless` flag
- **Automated execution**: Tests can be run automatically in build pipelines

## 🎯 Test Coverage

Current test coverage includes:

- ✅ **Core systems**: PlayerData, resource loading, equipment management
- ✅ **UI components**: Scene loading, path validation, button functionality
- ✅ **Error handling**: Invalid resources, corrupted files, missing data
- ✅ **Performance**: Large datasets, efficient operations
- ✅ **Data integrity**: Save/load, serialization, state management

## 🚀 Future Enhancements

Potential improvements for the testing framework:

1. **Visual test runner**: GUI for running and viewing test results
2. **Test coverage reporting**: Track which code paths are tested
3. **Mock objects**: Create mock objects for isolated testing
4. **Performance benchmarks**: Automated performance testing
5. **Integration tests**: End-to-end game flow testing
6. **Automated test generation**: Generate tests from code analysis 