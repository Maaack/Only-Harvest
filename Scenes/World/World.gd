extends Node2D

signal time_updated

@export var crop_tilemap : TileMap
@export var crop_tilemap_layer : int = 0
@export var crop_source_id : int = 0
var base_crop_scene = preload("res://Scenes/Crop/Crop.tscn")

@onready var characters_container = $Characters
var world_time : int = 0
var hours_in_day : int = 24

func increment_world_time(amount : int = 1):
	world_time += amount
	var container_children : Array[Node] = characters_container.get_children()
	for child in container_children:
		if child is Crop:
			child.increment_crop_age(amount)
	emit_signal("time_updated")

func _on_timer_timeout():
	increment_world_time()

func get_day():
	return floor(world_time / hours_in_day)

func get_hour():
	return world_time % hours_in_day

func _place_crop_scene_at_tile(crop_stage_data : CropStage , tile_coord : Vector2i):
	var tile_size : Vector2i = crop_tilemap.tile_set.tile_size
	var tiles_offset : Vector2 = (Vector2(tile_size) * 0.5) + crop_tilemap.position
	var crop_instance : Crop = base_crop_scene.instantiate()
	crop_instance.crop_type = crop_stage_data.type
	crop_instance.growth_stage = crop_stage_data.stage
	crop_instance.position = Vector2(tile_coord * crop_tilemap.tile_set.tile_size) + tiles_offset
	characters_container.add_child(crop_instance)

func _clear_crop_tile(tile_coord : Vector2i):
	crop_tilemap.set_cell(crop_tilemap_layer, tile_coord)

func _replace_crop_tiles_with_objects():
	var crop_tilemap_map = Constants.get_crop_tilemap()
	var used_cells : Array[Vector2i] = crop_tilemap.get_used_cells_by_id(crop_tilemap_layer, crop_source_id)
	print(used_cells)
	for used_cell in used_cells:
		var atlas_coord = crop_tilemap.get_cell_atlas_coords(crop_tilemap_layer, used_cell)
		if not atlas_coord in crop_tilemap_map:
			continue
		var crop_stage_data : CropStage = crop_tilemap_map[atlas_coord]
		_place_crop_scene_at_tile(crop_stage_data, used_cell)
		_clear_crop_tile(used_cell)

func _ready():
	_replace_crop_tiles_with_objects()
