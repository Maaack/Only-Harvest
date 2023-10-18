extends Node2D

signal time_updated
signal quickslots_updated(slot_array)
signal player_started_trespassing(faction : Constants.Factions)
signal player_stopped_trespassing(faction : Constants.Factions)

@export var crop_tilemap : TileMap
@export var crop_tilemap_layer : int = 0
@export var crop_source_id : int = 0
var base_crop_scene = preload("res://Scenes/Crop/Crop.tscn")
var base_crop_pickups_scene = preload("res://Scenes/Pickups/CropPickup.tscn")

@onready var characters_container = $Characters
@onready var collectibles_container = $Collectibles
@onready var properties_container = $Properties
@onready var player_character = %PlayerCharacter
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
	for used_cell in used_cells:
		var atlas_coord = crop_tilemap.get_cell_atlas_coords(crop_tilemap_layer, used_cell)
		if not atlas_coord in crop_tilemap_map:
			continue
		var crop_stage_data : CropStage = crop_tilemap_map[atlas_coord]
		_place_crop_scene_at_tile(crop_stage_data, used_cell)
		_clear_crop_tile(used_cell)

func _update_guard_dog_nav(guard_dog_node : GuardDog):
	guard_dog_node.next_navigation_points = [player_character.position]

func _connect_guard_dog(guard_dog_node : GuardDog):
	guard_dog_node.connect("nav_update_requested", _update_guard_dog_nav.bind(guard_dog_node))

func _connect_guard_dogs():
	var children : Array[Node] = characters_container.get_children()
	for child in children:
		if child is GuardDog:
			_connect_guard_dog(child)

func drop_crop_pickups(crop_type : Constants.Crops, center_position : Vector2, count : int = 1):
	for i in range(count):
		var crop_pickup_instance = base_crop_pickups_scene.instantiate()
		collectibles_container.call_deferred("add_child", crop_pickup_instance)
		crop_pickup_instance.position = center_position
		crop_pickup_instance.crop_type = crop_type
		crop_pickup_instance.bounce_away()

func _on_crop_harvested(crop_node : Crop):
	if crop_node == null:
		return
	var random_dist = min(max(0, randfn(2, 1)), 4)
	drop_crop_pickups(crop_node.crop_type, crop_node.position, random_dist)

func _connect_crop(crop_node : Crop):
	crop_node.connect("harvested", _on_crop_harvested.bind(crop_node))

func _connect_crops():
	var children : Array[Node] = characters_container.get_children()
	for child in children:
		if child is Crop:
			_connect_crop(child)

func _on_player_started_trespassing(faction : Constants.Factions):
	emit_signal("player_started_trespassing", faction)

func _on_player_stopped_trespassing(faction : Constants.Factions):
	emit_signal("player_stopped_trespassing", faction)

func _connect_property(property : PrivateProperty):
	property.connect("player_started_trespassing", _on_player_started_trespassing)
	property.connect("player_stopped_trespassing", _on_player_stopped_trespassing)

func _connect_properties():
	var children : Array[Node] = properties_container.get_children()
	for child in children:
		if child is PrivateProperty:
			_connect_property(child)

func _ready():
	_replace_crop_tiles_with_objects()
	_connect_guard_dogs()
	_connect_crops()
	_connect_properties()

func _on_player_character_quickslots_updated(slot_array):
	emit_signal("quickslots_updated", slot_array)
