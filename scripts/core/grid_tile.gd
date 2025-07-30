# GridTile.gd
# Represents a single tile in the Stellar Grid system
extends Resource
class_name GridTile

enum TileState { EMPTY, OCCUPIED, LOCKED }

# Tile properties
@export var grid_position: Vector2i
@export var tile_state: TileState = TileState.EMPTY
@export var placed_item: Item = null
@export var is_highlighted: bool = false

# Visual properties
@export var tile_color: Color = Color.DARK_GRAY
@export var highlight_color: Color = Color.YELLOW
@export var occupied_color: Color = Color.GREEN

signal tile_state_changed(new_state: TileState)
signal item_placed(item: Item)
signal item_removed(item: Item)

func _init():
	grid_position = Vector2i.ZERO
	tile_state = TileState.EMPTY
	placed_item = null

func place_item(item: Item) -> bool:
	"""Place an item on this tile"""
	if tile_state != TileState.EMPTY:
		print("Cannot place item on non-empty tile at: ", grid_position)
		return false
	
	if item == null:
		print("Cannot place null item on tile at: ", grid_position)
		return false
	
	placed_item = item
	tile_state = TileState.OCCUPIED
	item_placed.emit(item)
	tile_state_changed.emit(tile_state)
	
	print("Placed ", item.name, " on tile at: ", grid_position)
	return true

func remove_item() -> Item:
	"""Remove the item from this tile and return it"""
	if tile_state != TileState.OCCUPIED:
		print("Cannot remove item from empty tile at: ", grid_position)
		return null
	
	var removed_item = placed_item
	placed_item = null
	tile_state = TileState.EMPTY
	item_removed.emit(removed_item)
	tile_state_changed.emit(tile_state)
	
	print("Removed ", removed_item.name, " from tile at: ", grid_position)
	return removed_item

func is_empty() -> bool:
	"""Check if the tile is empty"""
	return tile_state == TileState.EMPTY

func is_occupied() -> bool:
	"""Check if the tile is occupied"""
	return tile_state == TileState.OCCUPIED

func is_locked() -> bool:
	"""Check if the tile is locked (future expansion)"""
	return tile_state == TileState.LOCKED

func get_item() -> Item:
	"""Get the item placed on this tile"""
	return placed_item

func set_highlight(highlight: bool):
	"""Set the highlight state of the tile"""
	is_highlighted = highlight

func get_display_color() -> Color:
	"""Get the appropriate color for displaying this tile"""
	if is_highlighted:
		return highlight_color
	elif tile_state == TileState.OCCUPIED:
		return occupied_color
	else:
		return tile_color

func get_tile_info() -> Dictionary:
	"""Get information about this tile for UI display"""
	var info = {
		"position": grid_position,
		"state": tile_state,
		"is_highlighted": is_highlighted,
		"item_name": "",
		"item_description": "",
		"production_info": {}
	}
	
	if placed_item != null:
		info.item_name = placed_item.name
		info.item_description = placed_item.description
		info.production_info = placed_item.stats.get("production", {})
	
	return info 