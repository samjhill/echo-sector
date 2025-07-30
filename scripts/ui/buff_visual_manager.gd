# BuffVisualManager.gd
# Manages visual indicators for adjacency buffs on the Stellar Grid
extends Node2D
class_name BuffVisualManager

# Visual settings
@export var show_buff_visuals: bool = true
@export var arrow_color: Color = Color.CYAN
@export var arrow_width: float = 2.0
@export var arrow_length: float = 20.0
@export var glow_intensity: float = 0.3

# Visual elements
var buff_lines: Array[Line2D] = []
var buff_arrows: Array[Line2D] = []
var buff_glows: Array[ColorRect] = []

# Grid reference
var grid_manager: GridManager = null
var grid_container: Control = null

signal buff_visuals_updated()

func _ready():
	# Initialize visual elements
	pass

func setup(grid_mgr: GridManager, grid_ctrl: Control):
	"""Setup the buff visual manager with grid references"""
	grid_manager = grid_mgr
	grid_container = grid_ctrl
	
	# Connect to grid manager signals
	if grid_manager:
		grid_manager.tile_placed.connect(_on_tile_placed)
		grid_manager.tile_removed.connect(_on_tile_removed)

func toggle_buff_visuals():
	"""Toggle the visibility of buff visuals"""
	show_buff_visuals = !show_buff_visuals
	update_all_buff_visuals()
	buff_visuals_updated.emit()

func update_all_buff_visuals():
	"""Update all buff visuals for the entire grid"""
	clear_buff_visuals()
	
	if not show_buff_visuals or not grid_manager:
		Logger.debug("Buff visuals disabled or grid manager not available", "BuffVisualManager")
		return
	
	Logger.info("Updating all buff visuals", "BuffVisualManager")
	
	# Calculate buff relationships for all tiles
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			var tile = grid_manager.get_tile(Vector2i(x, y))
			if tile and tile.is_occupied():
				_update_tile_buff_visuals(tile)
	
	Logger.info("Created %d buff arrows" % (buff_arrows.size() / 2), "BuffVisualManager")  # Divide by 2 because each arrow has 2 Line2D elements

func _update_tile_buff_visuals(tile: GridTile):
	"""Update buff visuals for a specific tile"""
	if not tile.is_occupied():
		return
	
	var item = tile.get_item()
	if not item:
		return
	
	# Check if this tile provides adjacency bonuses
	var provides_bonus = false
	if item.name.contains("Power Core") or item.name.contains("Research Lab"):
		provides_bonus = true
	
	if provides_bonus:
		# Find adjacent tiles that receive the bonus
		var adjacent_tiles = grid_manager.get_adjacent_tiles(tile.grid_position)
		var buff_targets: Array[Vector2i] = []
		
		for adjacent_tile in adjacent_tiles:
			if adjacent_tile.is_occupied():
				buff_targets.append(adjacent_tile.grid_position)
				# Mark adjacent tile as receiving buff
				adjacent_tile.set_receiving_buff([tile.grid_position])
		
		# Mark this tile as buffing adjacent tiles
		tile.set_buffing_adjacent(buff_targets)
		
		# Create visual arrows/lines
		_create_buff_visuals(tile.grid_position, buff_targets)

func _create_buff_visuals(source_pos: Vector2i, target_positions: Array[Vector2i]):
	"""Create visual indicators for buff relationships"""
	for target_pos in target_positions:
		_create_buff_arrow(source_pos, target_pos)

func _create_buff_arrow(from_pos: Vector2i, to_pos: Vector2i):
	"""Create an arrow pointing from source to target"""
	if not grid_container:
		return
	
	# Calculate positions in screen space
	var from_screen_pos = _grid_to_screen_position(from_pos)
	var to_screen_pos = _grid_to_screen_position(to_pos)
	
	# Add tile center offset to make arrows point to tile centers
	var tile_center_offset = Vector2(30, 30)  # Half of 60px tile
	from_screen_pos += tile_center_offset
	to_screen_pos += tile_center_offset
	
	# Create arrow line
	var arrow = Line2D.new()
	arrow.points = [from_screen_pos, to_screen_pos]
	arrow.width = arrow_width
	arrow.default_color = arrow_color
	arrow.antialiased = true
	arrow.joint_mode = Line2D.LINE_JOINT_ROUND
	arrow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	arrow.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	# Add arrowhead
	var direction = (to_screen_pos - from_screen_pos).normalized()
	var arrowhead_start = to_screen_pos - direction * arrow_length
	var arrowhead_left = arrowhead_start + direction.rotated(PI/6) * arrow_length * 0.5
	var arrowhead_right = arrowhead_start + direction.rotated(-PI/6) * arrow_length * 0.5
	
	var arrowhead = Line2D.new()
	arrowhead.points = [arrowhead_start, arrowhead_left, arrowhead_start, arrowhead_right]
	arrowhead.width = arrow_width
	arrowhead.default_color = arrow_color
	arrowhead.antialiased = true
	
	# Add to container
	grid_container.add_child(arrow)
	grid_container.add_child(arrowhead)
	
	# Store references
	buff_arrows.append(arrow)
	buff_arrows.append(arrowhead)
	
	Logger.debug("Created arrow from %s to %s" % [from_pos, to_pos], "BuffVisualManager")

func _grid_to_screen_position(grid_pos: Vector2i) -> Vector2:
	"""Convert grid position to screen position"""
	if not grid_container:
		return Vector2.ZERO
	
	# Get the actual grid container position and size
	var container_rect = grid_container.get_rect()
	var tile_size = 60.0  # Assuming 60px tiles
	var grid_offset = Vector2(4, 4)  # Grid separation
	
	# Calculate position within the grid container
	# For horizontal layout, x increases left to right, y increases top to bottom
	var grid_x = grid_pos.x * (tile_size + grid_offset.x)
	var grid_y = grid_pos.y * (tile_size + grid_offset.y)
	
	# Add container offset
	var screen_pos = Vector2(grid_x, grid_y) + container_rect.position
	
	Logger.debug("Grid pos %s -> Screen pos %s (container: %s)" % [grid_pos, screen_pos, container_rect], "BuffVisualManager")
	return screen_pos

func clear_buff_visuals():
	"""Clear all buff visual elements"""
	for arrow in buff_arrows:
		if is_instance_valid(arrow):
			arrow.queue_free()
	buff_arrows.clear()
	
	for glow in buff_glows:
		if is_instance_valid(glow):
			glow.queue_free()
	buff_glows.clear()

func _on_tile_placed(grid_position: Vector2i, item: Item):
	"""Handle tile placement - update buff visuals"""
	await get_tree().process_frame  # Wait for tile to be fully placed
	update_all_buff_visuals()

func _on_tile_removed(grid_position: Vector2i, item: Item):
	"""Handle tile removal - update buff visuals"""
	await get_tree().process_frame  # Wait for tile to be fully removed
	update_all_buff_visuals()

func get_buff_info_for_tile(tile: GridTile) -> Dictionary:
	"""Get buff information for a specific tile"""
	var info = {
		"is_buffing": tile.is_buffing_adjacent,
		"is_receiving": tile.is_receiving_buff,
		"buff_sources": tile.buff_source_positions.size(),
		"buff_targets": tile.buff_target_positions.size(),
		"total_bonus": 0.0
	}
	
	if tile.is_receiving_buff:
		info.total_bonus = tile.buff_source_positions.size() * 0.2  # +20% per buff source
	
	return info 