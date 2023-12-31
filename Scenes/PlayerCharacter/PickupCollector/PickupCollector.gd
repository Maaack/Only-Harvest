@tool
extends Node2D

signal pickup_collected(pickup)

@export var enabled : bool = true
@export var pull_area_force : float = 10
@export var pull_max_speed : float = 100
@export var pull_pickup_count : int = 1
@export var pull_area_shape : Shape2D : 
	set(value):
		pull_area_shape = value
		_update_areas()
@export var collect_area_shape : Shape2D : 
	set(value):
		collect_area_shape = value
		_update_areas()
@export var collect_delay : float = 0.1
@export var pull_distance_exponent : float = 2.0

var can_collect : bool = true
var pulling_pickups : Dictionary = {}
var collecting_pickups : Dictionary = {}

func _update_areas():
	if is_visible_in_tree():
		$PullArea2D/CollisionShape2D.shape = pull_area_shape
		$CollectArea2D/CollisionShape2D.shape = collect_area_shape

func _pull_pickup(pickup : Pickup, delta : float):
	pickup.is_dragged = true
	var shape_2d : CircleShape2D = $PullArea2D/CollisionShape2D.shape
	var parent_position = get_parent().position
	var distance = pickup.position.distance_to(parent_position)
	var ratio = shape_2d.radius / (distance + 0.0001)
	var squared_ratio = pow(ratio, pull_distance_exponent)
	var direction = pickup.position.direction_to(parent_position)
	pickup.velocity = pickup.velocity.move_toward(direction * pull_max_speed, squared_ratio * pull_area_force * delta)

func _drop_pickup(pickup : Pickup):
	pickup.is_dragged = false

func _physics_process(delta):
	if not enabled:
		return
	if pulling_pickups.size() == 0:
		return
	var pickups_array : Array = pulling_pickups.values()
	var max_pickups : int = min(pickups_array.size(), pull_pickup_count)
	var pickup_iter : int = 0
	for pickup in pickups_array:
		if pickup_iter >= max_pickups:
			break
		if pickup.is_draggable:
			_pull_pickup(pickup, delta)
			pickup_iter += 1
	var collecting_array : Array = collecting_pickups.values()
	if can_collect and collecting_array.size() > 0:
		var pickup : Pickup = collecting_array[0]
		emit_signal("pickup_collected", pickup)
		pickup.pickup()
		can_collect = false
		await(get_tree().create_timer(collect_delay, false, true).timeout)
		can_collect = true

func _on_pull_area_2d_body_entered(body):
	if body is Pickup and not body.is_dragged:
		pulling_pickups[body.get_instance_id()] = body

func _on_pull_area_2d_body_exited(body):
	if body is Pickup:
		_drop_pickup(body)
		pulling_pickups.erase(body.get_instance_id())

func _on_collect_area_2d_body_entered(body):
	if body is Pickup:
		collecting_pickups[body.get_instance_id()] = body

func _on_collect_area_2d_body_exited(body):
	if body is Pickup:
		collecting_pickups.erase(body.get_instance_id())

func _ready():
	_update_areas()
