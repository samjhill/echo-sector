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

#### Method 1: Command Line
```bash
./run_tests.sh
```

#### Method 2: Godot Editor
1. Open `res://tests/test_scene.tscn`
2. Run the scene to execute all tests

#### Method 3: Direct Script
```bash
godot --headless --script res://tests/run_tests.gd
```

### Test Coverage

The testing framework covers:

- ✅ **Core Systems**: PlayerData, resource loading, equipment management
- ✅ **UI Components**: Scene loading, path validation, button functionality  
- ✅ **Error Handling**: Invalid resources, corrupted files, missing data
- ✅ **Performance**: Large datasets, efficient operations
- ✅ **Data Integrity**: Save/load, serialization, state management

### Test Structure

```
tests/
├── unit/                    # Unit tests for core systems
├── ui/                      # UI integration tests
├── test_runner.gd          # Main test orchestrator
├── base_test_suite.gd      # Common testing utilities
└── README.md              # Detailed testing documentation
```

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
