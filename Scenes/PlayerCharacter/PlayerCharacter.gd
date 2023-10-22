extends CharacterBody2D
class_name PlayerCharacter

signal jump
signal killed
signal quickslots_updated(slot_array : Array)
signal quickslot_selected(slot : int)
signal trading_offered(buying : BaseQuantity, selling : BaseQuantity)
signal trading_revoked
signal dialogue_offered(action_name : String)
signal dialogue_revoked
signal seed_planted(seed : BaseQuantity, target_position : Vector2)
signal soil_hoed(target_position : Vector2)

@export var acceleration : float = 600
@export var max_speed : float = 7500
@export var friction : float = 600
@export var speed_mod : float = 1.0
@export var pull_count : int = 1 :
	set(value):
		pull_count = value
		if is_visible_in_tree():
			$PickupCollector.pull_pickup_count = pull_count

@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_tree = %CharacterAnimationTree
@onready var animation_state : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var axe_item : BaseUnit = preload("res://Resources/Items/Axe.tres")
var hoe_item : BaseUnit = preload("res://Resources/Items/Hoe.tres")
var seed_item : BaseUnit = preload("res://Resources/Items/SeedsWheat.tres")
var clock_item : BaseUnit = preload("res://Resources/Items/TimeWarp.tres")
var facing_direction : Vector2
var is_jumping : bool = false
var jump_input_flag : bool = false
var is_acting : bool = false
var action_input_flag : bool = false
var accessible_interactables : Array = []
var inventory : BaseContainer
var active_node
var selected_slot = 0
var is_dead : bool = false

func face_direction(new_direction : Vector2):
	facing_direction = new_direction.normalized()
	# var facing_angle = facing_direction.angle()
	animation_tree.set("parameters/Idle/blend_position", facing_direction)
	animation_tree.set("parameters/Walk/blend_position", facing_direction)
	animation_tree.set("parameters/Jump/blend_position", facing_direction)
	animation_tree.set("parameters/Harvest/blend_position", facing_direction)
	animation_tree.set("parameters/Plant/blend_position", facing_direction)
	animation_tree.set("parameters/Hoe/blend_position", facing_direction)

func start_jump():
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	animation_state.travel("Jump")
	is_jumping = true
	$JumpStreamPlayer2D.play()
	emit_signal("jump")

func finish_jump():
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	await(get_tree().create_timer(0.05).timeout)
	is_jumping = false
	jump_input_flag = false

func start_hoeing(target_position : Vector2):
	target_position += position
	emit_signal("soil_hoed", target_position)

func start_planting(target_position : Vector2):
	target_position += position
	var selected_tool : BaseQuantity = $QuickslotManager.get_selected_quantity()
	emit_signal("seed_planted", selected_tool, target_position)

func start_action():
	var selected_tool : BaseQuantity = $QuickslotManager.get_selected_quantity()
	if selected_tool.name == Constants.AXE_NAME:
		animation_state.travel("Harvest")
		$AxeSwingStreamPlayer2D.play()
	elif selected_tool.name == Constants.HOE_NAME:
		animation_state.travel("Hoe")
		$HoeSwingStreamPlayer2D.play()
	elif selected_tool.name.contains("Seeds"):
		if selected_tool.quantity < 1:
			return
		animation_state.travel("Plant")
	is_acting = true

func finish_action():
	await(get_tree().create_timer(0.05).timeout)
	is_acting = false
	action_input_flag = false

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	if jump_input_flag and not is_jumping:
		start_jump()
	if action_input_flag and not is_acting:
		start_action()
	if is_jumping:
		pass
	elif is_acting:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	elif input_vector != Vector2.ZERO:
		face_direction(input_vector)
		var desired_velocity = input_vector * max_speed * delta * speed_mod
		var desired_acceleration = acceleration * delta * speed_mod
		velocity = velocity.move_toward(desired_velocity, desired_acceleration)
		animation_state.travel("Walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta * speed_mod)
		animation_state.travel("Idle")
	move_and_slide()

func _physics_process(delta):
	move_state(delta)

func _ready():
	pull_count = pull_count
	await get_tree().create_timer(0.05).timeout
	inventory = BaseContainer.new()
	add_to_inventory(axe_item.duplicate(), true)
	_update_quickslot()

func _attempt_trade():
	if not active_node is TradingChest:
		return
	if inventory.has_content(active_node.buying):
		var trade_quantity = inventory.remove_content(active_node.buying)
		active_node.trade(trade_quantity)

func _attempt_dialogue():
	if not active_node is DialogueTrigger:
		return
	active_node.start_dialogue()

func _update_quickslot():
	if selected_slot < 0:
		selected_slot = 9
	if selected_slot > 9:
		selected_slot = 0
	$QuickslotManager.select_slot(selected_slot)
	emit_signal("quickslot_selected", selected_slot)

func _input(event):
	if event.is_action_pressed("jump"):
		jump_input_flag = true
	else:
		jump_input_flag = false
	if event.is_action_pressed("action"):
		var current_item : BaseQuantity = $QuickslotManager.get_selected_quantity()
		if current_item.taxonomy == Constants.TOOL_NAME and active_node == null:
			action_input_flag = true
		else:
			_attempt_trade()
			_attempt_dialogue()
	else:
		action_input_flag = false
	if event is InputEventKey and event.is_action_pressed("select_slot"):
		var key_code = event.keycode
		if key_code >= KEY_0 and key_code <= KEY_9 or key_code >= KEY_KP_0 and key_code <= KEY_KP_9:
			# Extract the numeric value from the key code
			selected_slot = key_code - KEY_0 if key_code >= KEY_0 and key_code <= KEY_9 else key_code - KEY_KP_0
			selected_slot -= 1
			_update_quickslot()
	if event.get_action_strength("next_slot"):
		selected_slot = $QuickslotManager.get_next_slot_by_taxonomy("Tool")
		_update_quickslot()
	elif event.get_action_strength("prev_slot"):
		selected_slot = $QuickslotManager.get_prev_slot_by_taxonomy("Tool")
		_update_quickslot()

func _on_action_area_area_entered(area):
	if area is Crop:
		area.try_harvest()

func add_to_inventory(item : BaseUnit, quietly : bool = false):
	if item == null:
		return
	inventory.add_content(item)
	var quantity = inventory.find_quantity(item.name)
	$QuickslotManager.add_quantity(quantity)
	if not quietly:
		$PickupStreamPlayer2D.play()
	emit_signal("quickslots_updated", $QuickslotManager.slot_array)
	if item.taxonomy == Constants.PASSIVE_NAME:
		if item.name == Constants.CLOCK_NAME:
			speed_mod = 1.5
			pull_count = 4

func remove_from_inventory(content:BaseUnit):
	if content == null:
		return
	inventory.remove_content(content)
	emit_signal("quickslots_updated", $QuickslotManager.slot_array)

func get_selected_item():
	var quantity = $QuickslotManager.get_selected_quantity()
	if is_instance_valid(quantity) and quantity is BaseQuantity:
		return inventory.find_content(quantity.name)

func _on_pickup_collector_pickup_collected(pickup):
	if pickup is QuantityPickup:
		var new_quantity : BaseQuantity = pickup.quantity.duplicate()
		add_to_inventory(new_quantity)

func _drop_all(quantity_name : String):
	var quantity = inventory.find_quantity(quantity_name)
	if quantity == null:
		return
	inventory.remove_content(quantity.duplicate())

func kill():
	if is_dead:
		return
	is_dead = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_physics_process(false)
	$PickupCollector.enabled = false
	_drop_all(Constants.STOLEN_EGGPLANT_NAME)
	_drop_all(Constants.STOLEN_WHEAT_NAME)
	emit_signal("killed")

func revive():
	is_dead = false
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	set_physics_process(true)
	$PickupCollector.enabled = true

func offer_trade(chest_node : TradingChest):
	active_node = chest_node
	emit_signal("trading_offered", chest_node.buying, chest_node.selling)

func revoke_trade():
	active_node = null
	emit_signal("trading_revoked")

func offer_dialogue(dialogue_trigger : DialogueTrigger):
	active_node = dialogue_trigger
	emit_signal("dialogue_offered", dialogue_trigger.action_name)

func revoke_dialogue():
	active_node = null
	emit_signal("dialogue_revoked")
