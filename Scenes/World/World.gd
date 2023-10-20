extends Node2D

signal time_updated
signal quickslots_updated(slot_array)
signal quickslot_selected(slot : int)
signal player_started_trespassing(faction : Constants.Factions)
signal player_stopped_trespassing(faction : Constants.Factions)
signal game_ended(days_passed : int, quantities : Array[BaseQuantity])
signal trading_offered(buying : BaseQuantity, selling : BaseQuantity)
signal trading_revoked

@export var crop_tilemap : TileMap
@export var crop_tilemap_layer : int = 0
@export var crop_source_id : int = 0
@export var game_over_days : int = 7
@export var start_time_offset : int = 12
@export var clear_layers_for_planting : Array[int] = []
@export var hoeing_layers : Array[int] = []
var base_crop_scene = preload("res://Scenes/Crop/Crop.tscn")
var base_pickups_scene = preload("res://Scenes/Pickups/QuantityPickup.tscn")
@onready var characters_container = $Characters
@onready var collectibles_container = $Collectibles
@onready var properties_container = $Properties
@onready var player_character = %PlayerCharacter
var world_time : int = 0
var hours_in_day : int = 24
var player_trespassing_properties : Array[Constants.Factions]

func _stop_player():
	player_character.set_collision_layer_value(1, false)
	player_character.set_collision_layer_value(5, false)
	player_character.set_physics_process(false)

func increment_world_time(amount : int = 1):
	world_time += amount
	var container_children : Array[Node] = characters_container.get_children()
	for child in container_children:
		if child is Crop:
			child.increment_crop_age(amount)
	if get_day() == game_over_days:
		get_tree().paused = true
		emit_signal("game_ended", get_day(), player_character.inventory.quantities)
	emit_signal("time_updated")

func _on_timer_timeout():
	increment_world_time()

func get_day():
	return floor((world_time + start_time_offset) / hours_in_day)

func get_hour():
	return (world_time + start_time_offset) % hours_in_day

func get_period() -> Constants.Periods:
	var hour = get_hour()
	if hour >= 6 and hour < 18:
		return Constants.Periods.DAY
	else:
		return Constants.Periods.NIGHT

func _place_crop_scene_at_tile(crop_stage_data : CropStage , tile_coord : Vector2i):
	var tile_size : Vector2i = crop_tilemap.tile_set.tile_size
	var tiles_offset : Vector2 = (Vector2(tile_size) * 0.5) + crop_tilemap.position
	var crop_instance : Crop = base_crop_scene.instantiate()
	crop_instance.crop_type = crop_stage_data.type
	crop_instance.growth_stage = crop_stage_data.stage
	crop_instance.position = Vector2(tile_coord * crop_tilemap.tile_set.tile_size) + tiles_offset
	characters_container.add_child(crop_instance)
	_set_planted_tile(tile_coord)

func _clear_crop_tile(tile_coord : Vector2i):
	crop_tilemap.set_cell(crop_tilemap_layer, tile_coord)

func _set_planted_tile(tile_coord : Vector2i):
	crop_tilemap.set_cell(crop_tilemap_layer, tile_coord, 1, Vector2i(5, 1))

func _replace_crop_tiles_with_objects():
	var crop_tilemap_map = Constants.get_crop_tilemap()
	var used_cells : Array[Vector2i] = crop_tilemap.get_used_cells_by_id(crop_tilemap_layer, crop_source_id)
	for used_cell in used_cells:
		var atlas_coord = crop_tilemap.get_cell_atlas_coords(crop_tilemap_layer, used_cell)
		if not atlas_coord in crop_tilemap_map:
			continue
		var crop_stage_data : CropStage = crop_tilemap_map[atlas_coord]
		_place_crop_scene_at_tile(crop_stage_data, used_cell)

func _update_guard_dog_nav(guard_dog_node : GuardDog):
	var target_position : Vector2
	if guard_dog_node.faction in player_trespassing_properties:
		target_position = player_character.position
	else:
		target_position = guard_dog_node.guard_position
	var points_array : Array = $AStarGridServer.get_world_path_avoiding_points(guard_dog_node.position, target_position)
	points_array.pop_front()
	guard_dog_node.next_navigation_points = points_array

func _connect_guard_dog(guard_dog_node : GuardDog):
	guard_dog_node.connect("nav_update_requested", _update_guard_dog_nav.bind(guard_dog_node))

func _connect_guard_dogs():
	var children : Array[Node] = characters_container.get_children()
	for child in children:
		if child is GuardDog:
			_connect_guard_dog(child)

func drop_crop_pickups(center_position : Vector2, quantity : BaseQuantity):
	var normalized_quantity : BaseQuantity = quantity.duplicate()
	normalized_quantity.quantity = 1
	for i in quantity.quantity:
		var crop_pickup_instance = base_pickups_scene.instantiate()
		collectibles_container.call_deferred("add_child", crop_pickup_instance)
		crop_pickup_instance.position = center_position
		crop_pickup_instance.quantity = normalized_quantity
		crop_pickup_instance.bounce_away()

func _on_crop_harvested(dropped : BaseQuantity, crop_node : Crop):
	if crop_node == null:
		return
	drop_crop_pickups(crop_node.position, dropped)
	var cell_coord : Vector2i = Vector2i(crop_node.position) / crop_tilemap.tile_set.tile_size
	_clear_crop_tile(cell_coord)

func _connect_crop(crop_node : Crop):
	crop_node.connect("harvested", _on_crop_harvested.bind(crop_node))

func _connect_crops():
	var children : Array[Node] = characters_container.get_children()
	for child in children:
		if child is Crop:
			_connect_crop(child)

func _on_player_started_trespassing(faction : Constants.Factions):
	emit_signal("player_started_trespassing", faction)
	player_trespassing_properties.append(faction)

func _on_player_stopped_trespassing(faction : Constants.Factions):
	emit_signal("player_stopped_trespassing", faction)
	player_trespassing_properties.erase(faction)

func _connect_property(property : PrivateProperty):
	property.connect("player_started_trespassing", _on_player_started_trespassing)
	property.connect("player_stopped_trespassing", _on_player_stopped_trespassing)

func _connect_properties():
	var children : Array[Node] = properties_container.get_children()
	for child in children:
		if child is PrivateProperty:
			_connect_property(child)

func drop_money_pickups(center_position : Vector2, quantity : BaseQuantity):
	var money_pickup_instance = base_pickups_scene.instantiate()
	collectibles_container.call_deferred("add_child", money_pickup_instance)
	money_pickup_instance.position = center_position
	money_pickup_instance.quantity = quantity
	money_pickup_instance.bounce_away()
		
func _on_chest_dropped(quantity : BaseQuantity, chest_node : Node2D):
	if chest_node == null:
		return
	drop_money_pickups(chest_node.position, quantity)

func _connect_chest(chest_node : Node2D):
	chest_node.connect("dropped", _on_chest_dropped.bind(chest_node))

func _connect_chests():
	var children : Array[Node] = characters_container.get_children()
	for child in children:
		if child is TradingChest:
			_connect_chest(child)

func _start_dialogue(dialogue_title : String):
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/MainStory.dialogue"), dialogue_title)
	get_tree().paused = true
	await(DialogueManager.dialogue_ended)
	get_tree().paused = false
	GameState.camera_target_player()

func _on_game_start_dialogue():
	await(get_tree().create_timer(0.5).timeout)
	_start_dialogue("Start")

func _ready():
	_replace_crop_tiles_with_objects()
	_connect_guard_dogs()
	_connect_crops()
	_connect_properties()
	_connect_chests()
	emit_signal("time_updated")
	_on_game_start_dialogue()

func _on_player_character_quickslots_updated(slot_array):
	emit_signal("quickslots_updated", slot_array)

func _respawn_player():
	player_character.position = %PlayerRespawnPoint.position
	player_character.revive()

func _pass_world_time(increments : int = 1, delay : float = 0.25):
	$Timer.paused = true
	var passed_time = 0
	while(passed_time < increments):
		await(get_tree().create_timer(delay, false, true).timeout)
		increment_world_time()
		passed_time += 1
	$Timer.paused = false

func _kill_player():
	player_character.position = %PlayerRespawnPoint.position
	_pass_world_time(8, 0.25)
	await(get_tree().create_timer(2, false, true).timeout)
	_respawn_player()

func _on_player_character_killed():
	_kill_player()

func _on_player_character_trading_offered(buying, selling):
	emit_signal("trading_offered", buying, selling)

func _on_player_character_trading_revoked():
	emit_signal("trading_revoked")

func _on_player_character_quickslot_selected(slot):
	emit_signal("quickslot_selected", slot)

func _is_tile_clear(tile_coord : Vector2i):
	for layer in clear_layers_for_planting:
		var source_id : int = crop_tilemap.get_cell_source_id(layer, tile_coord)
		if source_id > -1:
			return false
	return true

func _on_player_character_seed_planted(seed, target_position):
	var crop_type : Constants.Crops
	if seed.name.contains(Constants.WHEAT_NAME):
		crop_type = Constants.Crops.WHEAT
	elif seed.name.contains(Constants.EGGPLANT_NAME):
		crop_type = Constants.Crops.EGGPLANT
	var crop_stage_data : CropStage = CropStage.new(crop_type, Constants.Stages.ONE)
	var cell_coord : Vector2i = Vector2i(target_position) / crop_tilemap.tile_set.tile_size
	if not _is_tile_clear(cell_coord):
		return
	_place_crop_scene_at_tile(crop_stage_data, cell_coord)
	var one_seed : BaseQuantity = seed.duplicate()
	one_seed.quantity = 1
	player_character.inventory.remove_content(one_seed)

func _on_player_character_soil_hoed(target_position):
	for layer in hoeing_layers:
		var cell_coord : Vector2i = Vector2i(target_position) / crop_tilemap.tile_set.tile_size
		if crop_tilemap.get_cell_source_id(layer, cell_coord) > -1:
			crop_tilemap.set_cell(layer, cell_coord)
			if layer == 2:
				var surrounding_cells = crop_tilemap.get_surrounding_cells(cell_coord)
				var used_cells = crop_tilemap.get_used_cells(layer)
				var final_cells : Array = []
				for cell in surrounding_cells:
					if cell in used_cells:
						final_cells.append(cell)
				crop_tilemap.set_cells_terrain_connect(layer, final_cells, 0, 0)
			return
