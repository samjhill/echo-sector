#!/bin/bash

# Echo Sector File Structure Checker
# Validates that all required files are in place

echo "🔍 Echo Sector File Structure Checker"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter for results
total_checks=0
passed_checks=0
failed_checks=0

# Function to check if file exists
check_file() {
    local file_path="$1"
    local description="$2"
    
    total_checks=$((total_checks + 1))
    
    if [ -f "$file_path" ]; then
        echo -e "  ${GREEN}✅${NC} $description"
        passed_checks=$((passed_checks + 1))
    else
        echo -e "  ${RED}❌${NC} $description (missing: $file_path)"
        failed_checks=$((failed_checks + 1))
    fi
}

# Function to check if directory exists
check_directory() {
    local dir_path="$1"
    local description="$2"
    
    total_checks=$((total_checks + 1))
    
    if [ -d "$dir_path" ]; then
        echo -e "  ${GREEN}✅${NC} $description"
        passed_checks=$((passed_checks + 1))
    else
        echo -e "  ${RED}❌${NC} $description (missing: $dir_path)"
        failed_checks=$((failed_checks + 1))
    fi
}

echo "📁 Checking Project Structure..."
echo ""

echo "📋 Core Project Files:"
check_file "project.godot" "Project configuration file"
check_file "README.md" "Project README"

echo ""
echo "📋 Autoload Scripts:"
check_file "autoload/playerData.gd" "PlayerData autoload script"
check_file "autoload/build_version.gd" "BuildVersion autoload script"
check_file "autoload/inventory.gd" "Inventory autoload script"

echo ""
echo "📋 Core Scripts:"
check_file "scripts/core/item.gd" "Item base class"
check_file "components/engine_component.gd" "EngineComponent class"
check_file "scripts/core/player.gd" "Player script"
check_file "scripts/core/main.gd" "Main game script"

echo ""
echo "📋 UI Scripts:"
check_file "scripts/ui/hangar.gd" "Hangar UI script"
check_file "scripts/ui/ship_equipment_screen.gd" "Equipment screen script"
check_file "scripts/ui/animated_background.gd" "Animated background script"

echo ""
echo "📋 Weapon Scripts:"
check_file "components/laserWeapon.gd" "LaserWeapon class"
check_file "components/railgunWeapon.gd" "RailgunWeapon class"

echo ""
echo "📋 Engine Resources:"
check_file "components/basic_engine.tres" "Basic engine resource"
check_file "components/afterburner_engine.tres" "Afterburner engine resource"

echo ""
echo "📋 Scene Files:"
check_file "scenes/menus/hangar.tscn" "Hangar scene"
check_file "scenes/game/node_2d.tscn" "Main game scene"
check_file "scenes/ui/ship_equipment_screen.tscn" "Equipment screen scene"

echo ""
echo "📋 Texture Files:"
check_file "assets/textures/hangar.png" "Hangar background texture"
check_file "assets/textures/logo.png" "Logo texture"
check_file "assets/textures/ship.png" "Ship texture"
check_file "assets/textures/enemy_image.png" "Enemy texture"

echo ""
echo "📋 Directory Structure:"
check_directory "scripts" "Scripts directory"
check_directory "scenes" "Scenes directory"
check_directory "assets" "Assets directory"
check_directory "components" "Components directory"
check_directory "autoload" "Autoload directory"

echo ""
echo "=================================================="
echo "📊 FILE STRUCTURE CHECK RESULTS"
echo "=================================================="
echo "Total Checks: $total_checks"
echo "Passed: $passed_checks"
echo "Failed: $failed_checks"

if [ $failed_checks -eq 0 ]; then
    success_rate=100
else
    success_rate=$(( (passed_checks * 100) / total_checks ))
fi

echo "Success Rate: ${success_rate}%"
echo "=================================================="

if [ $failed_checks -eq 0 ]; then
    echo ""
    echo "🎉 All files are in place!"
    echo "✅ Your Echo Sector project structure is correct."
    echo "🚀 The game should work properly now."
    echo ""
    echo "To run the game:"
    echo "1. Open the project in Godot"
    echo "2. Run the hangar scene: res://scenes/menus/hangar.tscn"
    echo "3. Test the 'Launch Mission' and 'Ship Loadout' buttons"
    echo ""
    echo "🎨 The LAUNCH MISSION button now uses a rocket icon instead of emoji!"
    exit 0
else
    echo ""
    echo "❌ Some files are missing!"
    echo "🔧 Please check the missing files above and ensure they exist."
    exit 1
fi 