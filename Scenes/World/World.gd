extends Node2D

signal time_updated
signal time_passed
signal quickslots_updated(slot_array)
signal quickslot_selected(slot : int)
signal player_started_trespassing(faction : Constants.Factions)
signal player_stopped_trespassing(faction : Constants.Factions)
signal player_died
signal player_spawned
signal game_ended(days_passed : int, quantities : Array[BaseQuantity])
signal trading_offered(buying : BaseQuantity, selling : BaseQuantity)
signal trading_revoked
signal dialogue_offered(action_name : String)
signal dialogue_revoked
signal dialogue_started(title : String)

@export var crop_tilemap : TileMap
@export var crop_tilemap_layer : int = 0
@export var crop_source_id : int = 0
@export var game_over_days : int = 7
@export var start_time_offset : int = 12
var base_crop_scene = preload("res://Scenes/Crop/Crop.tscn")
var base_pickups_scene = preload("res://Scenes/Pickups/QuantityPickup.tscn")
@onready var characters_container = $Characters
@onready var collectibles_container = $Collectibles
@onready var dialogues_container = $Dialogues
@onready var properties_container = $Properties
@onready var player_character = %PlayerCharacter
var world_time : int = 0
var hours_in_day : int = 24
var player_trespassing_properties : Array[Constants.Factions]
var period_of_day : Constants.Periods

var has_trespassed_at_day : bool = false
var has_trespassed_at_night : bool = false
var has_started_first_night: bool = false
var player_is_dead : bool = false
var player_revivals : int = 0

func hold_player():
	player_character.set_physics_process(false)
	player_character.set_process_input(false)

func release_player():
	player_character.set_physics_process(true)
	player_character.set_process_input(true)

func _start_trespassing_dialogue():
	if player_trespassing_properties.size() == 0:
		return
	match period_of_day:
		Constants.Periods.DAY:
			if not has_trespassed_at_day:
				has_trespassed_at_day = true
				_start_dialogue("DayTrespassing")
		Constants.Periods.NIGHT:
			if not has_trespassed_at_night:
				has_trespassed_at_night = true
				_start_dialogue("NightTrespassing")

func _check_start_trespassing_timers():
	if player_trespassing_properties.size() == 0:
		return
	if period_of_day == Constants.Periods.NIGHT and not $KillShotTimer.is_stopped():
		$WarningShotTimer.stop()
		$KillShotTimer.stop()
	if period_of_day == Constants.Periods.DAY and $KillShotTimer.is_stopped():
		$WarningShotTimer.start()
		$KillShotTimer.start()

func _start_new_day():
	has_trespassed_at_day = false
	$NightMusicStreamPlayer.stop()
	$DayMusicStreamPlayer.play()

func _start_new_night():
	has_trespassed_at_night = false
	$DayMusicStreamPlayer.stop()
	$NightMusicStreamPlayer.play()
	if not has_started_first_night and not player_is_dead and player_trespassing_properties.is_empty():
		has_started_first_night = true
		_start_dialogue("FirstNight")

func _update_period_of_day():
	var new_period_of_day = _get_period_from_hour()
	if period_of_day != new_period_of_day:
		match(new_period_of_day):
			Constants.Periods.DAY:
				_start_new_day()
			Constants.Periods.NIGHT:
				_start_new_night()
		period_of_day = new_period_of_day

func increment_world_time(amount : int = 1):
	world_time += amount
	$DayNightModulater.add_time(amount)
	var container_children : Array[Node] = characters_container.get_children()
	for child in container_children:
		if child is Crop:
			child.increment_crop_age(amount)
	if world_time >= game_over_days * hours_in_day:
		$DayMusicStreamPlayer.stop()
		$NightMusicStreamPlayer.stop()
		$GameOverStreamPlayer.play()
		emit_signal("game_ended", get_day(), player_character.inventory.quantities)
	_update_period_of_day()
	_start_trespassing_dialogue()
	_check_start_trespassing_timers()
	emit_signal("time_updated")

func _on_timer_timeout():
	increment_world_time()

func get_day():
	return floor((world_time + start_time_offset) / hours_in_day)

func get_hour():
	return (world_time + start_time_offset) % hours_in_day

func _get_period_from_hour() -> Constants.Periods:
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
	_connect_crop(crop_instance)

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
	var tile_coord : Vector2i = _get_tile_coord_from_position(crop_node.position)
	_clear_crop_tile(tile_coord)

func _connect_crop(crop_node : Crop):
	crop_node.connect("harvested", _on_crop_harvested.bind(crop_node))

func _connect_crops():
	var children : Array[Node] = characters_container.get_children()
	for child in children:
		if child is Crop:
			_connect_crop(child)

func _on_player_started_trespassing(faction : Constants.Factions):
	player_trespassing_properties.append(faction)
	_start_trespassing_dialogue()
	_check_start_trespassing_timers()
	emit_signal("player_started_trespassing", faction)

func _on_player_stopped_trespassing(faction : Constants.Factions):
	emit_signal("player_stopped_trespassing", faction)
	$WarningShotTimer.stop()
	$KillShotTimer.stop()
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

func _connect_dialogue_trigger(dialogue_area : Node2D):
	dialogue_area.connect("dialogue_triggered", _start_dialogue)

func _connect_dialogue_triggers():
	var children : Array[Node] = dialogues_container.get_children()
	for child in children:
		if child is DialogueTrigger:
			_connect_dialogue_trigger(child)

func _start_dialogue(dialogue_title : String):
	emit_signal("dialogue_started", dialogue_title)

func _on_game_start_dialogue():
	await(get_tree().create_timer(0.5).timeout)
	_start_dialogue("Start")

func _ready():
	_replace_crop_tiles_with_objects()
	_connect_guard_dogs()
	_connect_properties()
	_connect_chests()
	_connect_dialogue_triggers()
	emit_signal("time_updated")
	_on_game_start_dialogue()

func _on_player_character_quickslots_updated(slot_array):
	emit_signal("quickslots_updated", slot_array)

func respawn_player():
	if not player_is_dead:
		return
	player_is_dead = false
	player_character.position = %PlayerRespawnPoint.position
	emit_signal("player_spawned")
	player_character.revive()
	player_revivals += 1
	match(player_revivals):
		1:
			_start_dialogue("FirstDeath")
		2:
			_start_dialogue("SecondDeath")
		3:
			_start_dialogue("ThirdDeath")
		4:
			_start_dialogue("FourthDeath")

func pass_world_time(increments : int = 1, delay : float = 0.25):
	$Timer.paused = true
	var passed_time = 0
	while(passed_time < increments):
		await(get_tree().create_timer(delay, false, true).timeout)
		increment_world_time()
		passed_time += 1
	$Timer.paused = false
	emit_signal("time_passed")

func _player_died():
	if player_is_dead:
		return
	player_is_dead = true
	$WarningShotTimer.stop()
	$KillShotTimer.stop()
	$DeathStreamPlayer.play()
	if not player_trespassing_properties.is_empty():
		emit_signal("player_stopped_trespassing", Constants.Factions.NONE)
		player_trespassing_properties.clear()
	emit_signal("player_died")

func _on_player_character_killed():
	_player_died()

func kill_player():
	player_character.kill()

func _on_player_character_trading_offered(buying, selling, can_buy):
	emit_signal("trading_offered", buying, selling, can_buy)

func _on_player_character_trading_revoked():
	emit_signal("trading_revoked")

func _on_player_character_dialogue_offered(action_name):
	emit_signal("dialogue_offered", action_name)

func _on_player_character_dialogue_revoked():
	emit_signal("dialogue_revoked")

func _on_player_character_quickslot_selected(slot):
	emit_signal("quickslot_selected", slot)
	$TileHighlighter.hide()

func _is_tile_clear_for_tool(tile_coord : Vector2i, tile_tool : Constants.TileTool):
	var layers : Array
	match(tile_tool):
		Constants.TileTool.SEEDS:
			layers = Constants.EMPTY_LAYERS_FOR_PLANTING
		Constants.TileTool.HOE:
			layers = Constants.EMPTY_LAYERS_FOR_HOEING
	for layer in layers:
		var source_id : int = crop_tilemap.get_cell_source_id(layer, tile_coord)
		if source_id > -1:
			return false
	return true

func _is_tile_filled_for_tool(tile_coord : Vector2i, tile_tool : Constants.TileTool):
	var layers : Array
	match(tile_tool):
		Constants.TileTool.SEEDS:
			# Map condition enforces this by using dirt tiles everywhere
			return true
		Constants.TileTool.HOE:
			layers = Constants.FILLED_LAYERS_FOR_HOEING
	for layer in layers:
		var source_id : int = crop_tilemap.get_cell_source_id(layer, tile_coord)
		if source_id > -1:
			return true
	return false

func _get_tile_coord_from_position(target_position):
	return Vector2i(target_position) / crop_tilemap.tile_set.tile_size

func _on_player_character_seed_planted(seed, target_position):
	var crop_type : Constants.Crops
	if seed.name.contains(Constants.WHEAT_NAME):
		crop_type = Constants.Crops.WHEAT
	elif seed.name.contains(Constants.EGGPLANT_NAME):
		crop_type = Constants.Crops.EGGPLANT
	var crop_stage_data : CropStage = CropStage.new(crop_type, Constants.Stages.ONE)
	var tile_coord : Vector2i = _get_tile_coord_from_position(target_position)
	if not _is_tile_clear_for_tool(tile_coord, Constants.TileTool.SEEDS):
		return
	_place_crop_scene_at_tile(crop_stage_data, tile_coord)
	var one_seed : BaseQuantity = seed.duplicate()
	one_seed.quantity = 1
	player_character.inventory.remove_content(one_seed)

func _on_player_character_soil_hoed(target_position):
	for layer in Constants.FILLED_LAYERS_FOR_HOEING:
		var tile_coord : Vector2i = Vector2i(target_position) / crop_tilemap.tile_set.tile_size
		if crop_tilemap.get_cell_source_id(layer, tile_coord) > -1:
			crop_tilemap.set_cell(layer, tile_coord)
			if layer == 2:
				var surrounding_cells = crop_tilemap.get_surrounding_cells(tile_coord)
				var used_cells = crop_tilemap.get_used_cells(layer)
				var final_cells : Array = []
				for cell in surrounding_cells:
					if cell in used_cells:
						final_cells.append(cell)
				crop_tilemap.set_cells_terrain_connect(layer, final_cells, 0, 0)
			return

func _on_warning_shot_timer_timeout():
	_start_dialogue("WarningShot")

func _on_kill_shot_timer_timeout():
	_start_dialogue("KillShot")

func _center_to_tile(target_position):
	var tile_coord : Vector2i = _get_tile_coord_from_position(target_position)
	return Vector2(tile_coord * crop_tilemap.tile_set.tile_size + crop_tilemap.tile_set.tile_size / 2)

func _on_player_character_tile_highlighted(target_position, tile_tool):
	var tile_coord : Vector2i = _get_tile_coord_from_position(target_position)
	if not _is_tile_clear_for_tool(tile_coord, tile_tool) or not _is_tile_filled_for_tool(tile_coord, tile_tool):
		$TileHighlighter.hide()
		return
	$TileHighlighter.show()
	$TileHighlighter.position = _center_to_tile(target_position)
