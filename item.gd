# item.gd
extends Resource
class_name Item
@export var id: StringName
@export var name: String
@export var description: String
@export var icon: Texture2D
@export_enum("weapon", "engine", "shield", "material", "quest") var type: String
@export var slot_type: String = "" # e.g., "weapon", "engine", "shield", etc.
@export var is_equippable: bool = false
@export var is_stackable: bool = false
@export var max_stack: int = 1
# stats is already present, but clarify its use for extensibility
@export var stats := {} # e.g., {"damage": 10, "cooldown": 1.0, "thrust": 200.0}
# For future extensibility: effects, modifiers, etc.
@export var effects: Array = [] # e.g., [{"type": "heal", "amount": 5}]
@export var icon_path: String = ""
