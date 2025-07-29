#!/bin/bash

# Echo Sector Test Runner
echo "🧪 Echo Sector Test Runner"
echo "=========================="

# Find Godot executable
GODOT_PATH=""
if command -v godot &> /dev/null; then
    GODOT_PATH="godot"
    echo "✅ Godot found in PATH"
elif [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
    echo "✅ Godot found in Applications"
elif [ -f "/usr/local/bin/godot" ]; then
    GODOT_PATH="/usr/local/bin/godot"
    echo "✅ Godot found in /usr/local/bin"
elif [ -f "/opt/godot/godot" ]; then
    GODOT_PATH="/opt/godot/godot"
    echo "✅ Godot found in /opt/godot"
else
    echo "❌ Error: Godot is not installed or not in PATH"
    echo "Please install Godot and ensure it's available in your PATH"
    exit 1
fi

# Get Godot version
GODOT_VERSION=$($GODOT_PATH --version 2>/dev/null | head -n 1)
echo "🚀 Running tests with: $GODOT_VERSION"

# Run the file structure check first (most reliable)
echo "🔍 Running file structure validation..."
if ./check_files.sh; then
    echo "✅ File structure validation passed"
else
    echo "❌ File structure validation failed"
    exit 1
fi

# Run Godot-based tests with timeout
echo "🧪 Running Godot-based tests..."
echo "🧪 Running basic tests..."

# Run with timeout to prevent hanging
timeout 30s $GODOT_PATH --headless --script res://tests/basic_tests.gd

# Check if the command timed out
if [ $? -eq 124 ]; then
    echo "⏰ Tests timed out after 30 seconds"
    echo "🔧 This might be due to resource import issues or autoload dependencies"
    echo "💡 Try opening the project in Godot editor first to import resources"
    exit 1
elif [ $? -eq 0 ]; then
    echo "✅ Godot tests completed successfully"
else
    echo "❌ Some tests failed! Check the file structure and paths."
    echo "🔧 Please check the missing files above and ensure they exist."
    exit 1
fi

echo "🎉 All tests completed!" 