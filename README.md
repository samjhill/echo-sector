# 🚀 Echo Sector

**Echo Sector** is a chill, strategic 2D space survival shooter inspired by the Abyssal Deadspace runs in *EVE Online*. You pilot a modular ship with autonomous drones and fight your way through randomized enemies in an eerie, collapsing sector of space.

The game is designed to be highly playable on both mobile and desktop, with tap-to-target and orbit-style movement mechanics.

[▶️ Play Now](https://samjhill.github.io/echo-sector/)

---

## 🕹️ Gameplay

- Tap or click to move to a location
- Tap enemies to lock on and begin firing
- Your ship will automatically orbit enemies in range
- Earn credits for each kill
- Survive the waves, find the exit portal, and escape alive

Persistent progression (unlockables, etc.) is coming soon!

---

## 🧪 Testing

Echo Sector includes a comprehensive automated testing framework to ensure code quality and prevent regressions.

### Running Tests

#### Method 1: Command Line (Recommended)
```bash
./run_tests.sh
```

#### Method 2: Godot Editor
1. Open `res://tests/test_scene.tscn`
2. Run the scene to execute all tests

#### Method 3: Direct Script
```bash
godot --headless --script res://tests/comprehensive_test_runner.gd
```

### Test Coverage

The comprehensive testing framework covers:

- ✅ **Core Systems**: PlayerData, resource loading, equipment management
- ✅ **Stellar Grid**: Grid management, item placement, production system
- ✅ **UI Components**: Scene loading, path validation, button functionality  
- ✅ **Error Handling**: Invalid resources, corrupted files, missing data
- ✅ **Performance**: Large datasets, efficient operations
- ✅ **Data Integrity**: Save/load, serialization, state management
- ✅ **Logging**: Structured logging with different levels
- ✅ **Mobile Support**: Touch input, long press, responsive design

### Test Structure

```
tests/
├── unit/                           # Unit tests for core systems
│   ├── test_player_data.gd        # PlayerData autoload tests
│   ├── test_resource_loading.gd   # Resource loading tests
│   ├── test_equipment_system.gd   # Equipment system tests
│   └── test_stellar_grid.gd       # Stellar Grid system tests
├── ui/                             # UI integration tests
│   └── test_ui_integration.gd     # UI and scene tests
├── comprehensive_test_runner.gd    # Main comprehensive test runner
├── base_test_suite.gd             # Common testing utilities
└── README.md                      # Detailed testing documentation
```

### Code Quality Features

- 🔍 **Structured Logging**: Replaced debug prints with proper logging system
- 🧹 **Code Cleanup**: Removed commented code and debug statements
- 📝 **Documentation**: Added comprehensive docstrings
- 🎯 **Best Practices**: Following Godot coding standards
- 🧪 **Comprehensive Tests**: 50+ test cases covering all major systems

For detailed testing documentation, see [tests/README.md](tests/README.md).

---

## 🛠️ Development

### Prerequisites
- Godot 4.2.2 or later
- Git

### Setup
1. Clone the repository
2. Open the project in Godot
3. Run tests to verify everything works: `./run_tests.sh`

### Continuous Integration
Tests run automatically on every commit and pull request via GitHub Actions.
