#!/bin/bash

# Echo Sector File Structure Checker
# This script checks that all required files exist in the correct locations

echo "🔍 Echo Sector File Structure Checker"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if file exists
check_file() {
    local file_path="$1"
    local description="$2"
    
    if [ -f "$file_path" ]; then
        echo -e "  ${GREEN}✅${NC} $description"
        return 0
    else
        echo -e "  ${RED}❌${NC} $description (missing: $file_path)"
        return 1
    fi
}

# Function to check if directory exists
check_directory() {
    local dir_path="$1"
    local description="$2"
    
    if [ -d "$dir_path" ]; then
        echo -e "  ${GREEN}✅${NC} $description"
        return 0
    else
        echo -e "  ${RED}❌${NC} $description (missing: $dir_path)"
        return 1
    fi
}

echo ""
echo "📁 Checking Project Structure..."

total_checks=0
passed_checks=0

# Check main project files
echo ""
echo "📋 Core Project Files:"
check_file "project.godot" "Project configuration file" && ((passed_checks++)) || true
((total_checks++))

check_file "README.md" "Project README" && ((passed_checks++)) || true
((total_checks++))

# Check autoload scripts
echo ""
echo "📋 Autoload Scripts:"
check_file "autoload/playerData.gd" "PlayerData autoload script" && ((passed_checks++)) || true
((total_checks++))

check_file "autoload/build_version.gd" "BuildVersion autoload script" && ((passed_checks++)) || true
((total_checks++))

check_file "autoload/inventory.gd" "Inventory autoload script" && ((passed_checks++)) || true
((total_checks++))

# Check core scripts
echo ""
echo "📋 Core Scripts:"
check_file "scripts/core/item.gd" "Item base class" && ((passed_checks++)) || true
((total_checks++))

check_file "components/engine_component.gd" "EngineComponent class" && ((passed_checks++)) || true
((total_checks++))

check_file "scripts/core/player.gd" "Player script" && ((passed_checks++)) || true
((total_checks++))

check_file "scripts/core/main.gd" "Main game script" && ((passed_checks++)) || true
((total_checks++))

# Check UI scripts
echo ""
echo "📋 UI Scripts:"
check_file "scripts/ui/hangar.gd" "Hangar UI script" && ((passed_checks++)) || true
((total_checks++))

check_file "scripts/ui/ship_equipment_screen.gd" "Equipment screen script" && ((passed_checks++)) || true
((total_checks++))

# Check weapon scripts
echo ""
echo "📋 Weapon Scripts:"
check_file "components/laserWeapon.gd" "LaserWeapon class" && ((passed_checks++)) || true
((total_checks++))

check_file "components/railgunWeapon.gd" "RailgunWeapon class" && ((passed_checks++)) || true
((total_checks++))

# Check engine resources
echo ""
echo "📋 Engine Resources:"
check_file "components/basic_engine.tres" "Basic engine resource" && ((passed_checks++)) || true
((total_checks++))

check_file "components/afterburner_engine.tres" "Afterburner engine resource" && ((passed_checks++)) || true
((total_checks++))

# Check scenes
echo ""
echo "📋 Scene Files:"
check_file "scenes/menus/hangar.tscn" "Hangar scene" && ((passed_checks++)) || true
((total_checks++))

check_file "scenes/game/node_2d.tscn" "Main game scene" && ((passed_checks++)) || true
((total_checks++))

check_file "scenes/ui/ship_equipment_screen.tscn" "Equipment screen scene" && ((passed_checks++)) || true
((total_checks++))

# Check textures
echo ""
echo "📋 Texture Files:"
check_file "assets/textures/hangar.png" "Hangar background texture" && ((passed_checks++)) || true
((total_checks++))

check_file "assets/textures/logo.png" "Logo texture" && ((passed_checks++)) || true
((total_checks++))

check_file "assets/textures/ship.png" "Ship texture" && ((passed_checks++)) || true
((total_checks++))

check_file "assets/textures/enemy_image.png" "Enemy texture" && ((passed_checks++)) || true
((total_checks++))

# Check directories
echo ""
echo "📋 Directory Structure:"
check_directory "scripts" "Scripts directory" && ((passed_checks++)) || true
((total_checks++))

check_directory "scenes" "Scenes directory" && ((passed_checks++)) || true
((total_checks++))

check_directory "assets" "Assets directory" && ((passed_checks++)) || true
((total_checks++))

check_directory "components" "Components directory" && ((passed_checks++)) || true
((total_checks++))

check_directory "autoload" "Autoload directory" && ((passed_checks++)) || true
((total_checks++))

# Print results
echo ""
echo "=================================================="
echo "📊 FILE STRUCTURE CHECK RESULTS"
echo "=================================================="
echo "Total Checks: $total_checks"
echo "Passed: $passed_checks"
echo "Failed: $((total_checks - passed_checks))"

if [ $passed_checks -eq $total_checks ]; then
    success_rate=100
else
    success_rate=$((passed_checks * 100 / total_checks))
fi

echo "Success Rate: ${success_rate}%"
echo "=================================================="

if [ $passed_checks -eq $total_checks ]; then
    echo ""
    echo -e "${GREEN}🎉 All files are in place!${NC}"
    echo "✅ Your Echo Sector project structure is correct."
    echo "🚀 The game should work properly now."
    echo ""
    echo "To run the game:"
    echo "1. Open the project in Godot"
    echo "2. Run the hangar scene: res://scenes/menus/hangar.tscn"
    echo "3. Test the 'Launch Mission' and 'Ship Loadout' buttons"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Some files are missing!${NC}"
    echo "🔧 Please check the missing files above and ensure they exist."
    echo "📁 Make sure all file paths are correct."
    exit 1
fi 