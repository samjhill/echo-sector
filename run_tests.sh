#!/bin/bash

# Echo Sector Test Runner Script
# This script runs the automated tests for the Echo Sector game

echo "🧪 Echo Sector Test Runner"
echo "=========================="

# Check for Godot in different locations
GODOT_PATH=""

# Check if godot is in PATH
if command -v godot &> /dev/null; then
    GODOT_PATH="godot"
    echo "✅ Godot found in PATH"
# Check for Godot in Applications (macOS)
elif [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
    echo "✅ Godot found in Applications"
# Check for Godot in common Linux locations
elif [ -f "/usr/bin/godot" ]; then
    GODOT_PATH="/usr/bin/godot"
    echo "✅ Godot found in /usr/bin"
elif [ -f "/usr/local/bin/godot" ]; then
    GODOT_PATH="/usr/local/bin/godot"
    echo "✅ Godot found in /usr/local/bin"
else
    echo "❌ Error: Godot is not installed or not found"
    echo "Please install Godot and ensure it's available in one of these locations:"
    echo "  - PATH (godot command)"
    echo "  - /Applications/Godot.app/Contents/MacOS/Godot (macOS)"
    echo "  - /usr/bin/godot (Linux)"
    echo "  - /usr/local/bin/godot (Linux)"
    exit 1
fi

# Show Godot version
echo "🚀 Running tests with: $($GODOT_PATH --version | head -n 1)"

# Run tests in headless mode using the basic test runner
echo "🧪 Running basic tests..."
$GODOT_PATH --headless --script res://tests/basic_tests.gd

# Check exit code
if [ $? -eq 0 ]; then
    echo "✅ All basic tests passed!"
    echo ""
    echo "🎉 Your Echo Sector project structure is correct!"
    echo "📁 All required files exist and can be loaded."
    echo "🚀 The game should work properly now."
    exit 0
else
    echo "❌ Some tests failed!"
    echo ""
    echo "🔧 Please check the file structure and ensure all paths are correct."
    exit 1
fi 