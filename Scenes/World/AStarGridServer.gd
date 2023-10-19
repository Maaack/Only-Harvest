extends Node2D
class_name AStarGridServer

var astar : AStarGrid2D
@export var region : Rect2i = Rect2i(0, 0, 32, 32)
@export var cell_size : Vector2i = Vector2i(16, 16)
@export var exclude_tilemaps : Array[TileMap]
@export var exclude_tilemap_layers : Array[int] = []
@export var collision_groups : Array[String]
@export var radius_padding : float = 0
@export var size_padding : float = 0 
@export var update_points_per_frame : int = 50
@export_category("Debugging")
@export var debug_cell_texture : Texture
@export var debug_update_time : float = 5
var nonsolid_astar_points : Array[Vector2i]
var nonsolid_astar_iter : int = 0
var dynamic_nodes_array : Array
var current_debug_update_time : float = 0

func set_path_length(point_path: Array, max_distance: int) -> Array:
	if max_distance < 0: 
		return point_path
	point_path.resize(min(point_path.size(), max_distance))
	return point_path

func exclude_tilemap(tilemap : TileMap):
	var excluded_tiles : Array[Vector2i] = []
	var x_size = region.size.x
	var y_size = region.size.y
	for layer in exclude_tilemap_layers:
		for x in range(x_size):
			for y in range(y_size):
				var astar_vector = Vector2i(x, y) + region.position
				var ratio = Vector2(cell_size) / Vector2(tilemap.tile_set.tile_size)
				var x_total = floor(astar_vector.x * ratio.x)
				var y_total = floor(astar_vector.y * ratio.y)
				var coord2i = Vector2i(x_total, y_total)
				if coord2i in excluded_tiles:
					astar.set_point_solid(astar_vector, true)
					continue
				var results = tilemap.get_cell_source_id(layer, coord2i)
				if results > -1:
					astar.set_point_solid(astar_vector, true)
					excluded_tiles.append(coord2i)

func _save_nonsolid_points():
	nonsolid_astar_points.clear()
	var x_size = region.size.x
	var y_size = region.size.y
	for x in range(x_size):
		for y in range(y_size):
			var cell_vector2i = (Vector2i(x, y) + region.position)
			if astar.is_in_boundsv(cell_vector2i) and not astar.is_point_solid(cell_vector2i):
				nonsolid_astar_points.append(cell_vector2i)

func _save_dynamic_nodes():
	dynamic_nodes_array.clear()
	for group_name in collision_groups:
		var group_nodes = get_tree().get_nodes_in_group(group_name)
		dynamic_nodes_array.append_array(group_nodes)

func debug_navigation_points():
	if not get_tree().debug_navigation_hint:
		return
	var children_array : Array = get_children()
	for child in children_array:
		child.queue_free()
	if debug_cell_texture == null:
		return
	var x_size = region.size.x
	var y_size = region.size.y
	for x in range(x_size):
		for y in range(y_size):
			var cell_vector2i = (Vector2i(x, y) + region.position)
			if not astar.is_in_boundsv(cell_vector2i) or astar.is_point_solid(cell_vector2i):
				continue
			var cell_sprite_instance = Sprite2D.new()
			cell_sprite_instance.position = Vector2i(astar.get_point_position(cell_vector2i)) + get_half_cell_size()
			cell_sprite_instance.texture = debug_cell_texture
			call_deferred("add_child", cell_sprite_instance)

func _check_circle_overlap(circle_shape : CircleShape2D, check_position):
	return Vector2(check_position).length_squared() < pow(circle_shape.radius + radius_padding, 2)

func _check_rect_overlap(rect_shape : RectangleShape2D, check_position):
	var rectangle_quarter : Vector2 = (rect_shape.size / 2) + Vector2(size_padding, size_padding)
	return rectangle_quarter.x > check_position.x and rectangle_quarter.y > check_position.y

func _check_point_collides(tile_position : Vector2):
	for node in dynamic_nodes_array:
		if not is_instance_valid(node):
			continue
		var collision_shape : CollisionShape2D = node.get_node("CollisionShape2D")
		if collision_shape.disabled:
			continue
		var relative_position = abs(tile_position - (node.position + collision_shape.position))
		var shape_2d : Shape2D = node.get_node("CollisionShape2D").shape
		if shape_2d is CircleShape2D:
			if _check_circle_overlap(shape_2d, relative_position):
				return true
		elif shape_2d is RectangleShape2D:
			if _check_rect_overlap(shape_2d, relative_position):
				return true
	return false

func _call_update_nonsolid_points(max_point_checks : int = 100):
	var cells_checked : int = 0
	var half_cell_size : Vector2i = get_half_cell_size()
	while(cells_checked < max_point_checks):
		nonsolid_astar_iter += 1
		if nonsolid_astar_iter >= nonsolid_astar_points.size():
			nonsolid_astar_iter = 0
		var nonsolid_astar_point = nonsolid_astar_points[nonsolid_astar_iter]
		if _check_point_collides((nonsolid_astar_point * cell_size) + half_cell_size):
			astar.set_point_solid(nonsolid_astar_point, true)
		else:
			astar.set_point_solid(nonsolid_astar_point, false)
		cells_checked += 1

func _process_debug(delta):
	if not get_tree().debug_navigation_hint:
		return
	if debug_update_time <= 0:
		return
	current_debug_update_time += delta
	if current_debug_update_time < debug_update_time:
		return
	current_debug_update_time = debug_update_time - current_debug_update_time
	debug_navigation_points()

func _process(delta):
	_save_dynamic_nodes()
	_call_update_nonsolid_points(update_points_per_frame)
	_process_debug(delta)

func _ready_astargrid():
	astar = AStarGrid2D.new()
	astar.region = region
	astar.cell_size = Vector2(cell_size)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.jumping_enabled = true
	astar.update()

func _ready_wall_points():
	for tilemap in exclude_tilemaps:
		exclude_tilemap(tilemap)
	_save_nonsolid_points()

func _ready() -> void:
	_ready_astargrid()
	_ready_wall_points()
	debug_navigation_points()

func set_points_disabled(points : Array, disabled : bool = true) -> void:
	for point_vector in points:
		point_vector = Vector2i(point_vector)
		if astar.is_in_boundsv(point_vector):
			astar.set_point_solid(point_vector, disabled)

func get_astar_path(start_cell: Vector2, end_cell: Vector2, max_distance := -1) -> Array:
	if not astar.is_in_boundsv(start_cell) or not astar.is_in_boundsv(end_cell):
		return []
	var astar_path := astar.get_point_path(start_cell, end_cell)
	return set_path_length(astar_path, max_distance)

func get_astar_path_avoiding_points(start_cell: Vector2, end_cell: Vector2, avoid_cells : Array = [], max_distance := -1) -> Array:
	set_points_disabled(avoid_cells)
	var astar_path := get_astar_path(start_cell, end_cell, max_distance)
	set_points_disabled(avoid_cells, false)
	return astar_path
	
func get_half_cell_size() -> Vector2i:
	return cell_size / 2

func get_nearest_tile_position(check_position : Vector2) -> Vector2i :
	return (Vector2i(round(check_position))) / cell_size

func get_world_path_avoiding_points(start_position: Vector2, end_position: Vector2, avoid_positions : Array = [], max_distance := -1) -> Array:
	var start_cell := get_nearest_tile_position(start_position)
	var end_cell := get_nearest_tile_position(end_position)
	var avoid_cells := []
	for avoid_position in avoid_positions:
		avoid_cells.append(get_nearest_tile_position(avoid_position))
	var return_path = get_astar_path_avoiding_points(start_cell, end_cell, avoid_cells, max_distance)
	return add_half_cell_to_path(return_path)

func add_half_cell_to_path(path : Array) -> Array[Vector2]:
	var return_path : Array[Vector2] = []
	for cell_vector in path:
		return_path.append(cell_vector + Vector2(get_half_cell_size()))
	return return_path
