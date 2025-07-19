# item.gd
extends Resource
class_name Item
@export var id: StringName
@export var name: String
@export var description: String
@export var icon: Texture2D
@export_enum("weapon", "engine", "shield", "material", "quest") var type: String
@export var stats := {}
