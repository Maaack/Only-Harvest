extends CharacterBody2D
class_name GuardDog

signal nav_update_requested

const MIN_TARGET_MOVE_DISTANCE = 3.0

@export var movement_speed = 4000
@export var friction : float = 1000
@export var faction : Constants.Factions = Constants.Factions.NONE
@export var nav_refresh_rate : float = 1.0
@export_enum("Low", "High") var aggression_level : int = 0

@onready var character_animation_tree = $AnimationTree
@onready var character_state_machine : AnimationNodeStateMachinePlayback = character_animation_tree.get("parameters/playback")
@onready var guard_position : Vector2 = position

var sees_player : bool = true
var move_target : Vector2
var next_navigation_points : Array[Vector2] = [] # the next navigation path where the character should head to

func _get_movement_speed():
	var aggression_mod : float = 1.4 if aggression_level == 1 else 1.0
	return movement_speed * aggression_mod

func _face_direction(direction : Vector2):
	character_animation_tree.set("parameters/Idle/blend_position", direction.x)
	character_animation_tree.set("parameters/Walk/blend_position", direction.x)
	
func _move_to_target(target : Vector2, speed : float):
	velocity = position.direction_to(target) * speed
	var direction = velocity.normalized()
	_face_direction(direction)

func _is_stopped_state():
	return not sees_player or (_get_navigation_point() - position).length_squared() < pow(MIN_TARGET_MOVE_DISTANCE, 2)

func _process_movement(target : Vector2, speed : float, delta : float):
	if _is_stopped_state():
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		character_state_machine.travel("Idle")
	else:
		_move_to_target(target, speed * delta)
		character_state_machine.travel("Walk")
	move_and_slide()
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var body = collision.get_collider()
		if body is PlayerCharacter:
			body.kill()

func _get_navigation_point():
	if next_navigation_points.is_empty():
		return position
	var next_navigation_point = next_navigation_points[0]
	if next_navigation_points.size() > 1 and (next_navigation_point - position).length_squared() < pow(MIN_TARGET_MOVE_DISTANCE,2):
		next_navigation_points = next_navigation_points.slice(1)
		next_navigation_point = next_navigation_points[0]
	return next_navigation_point

func _physics_process(delta):
	var next_navigation_point = _get_navigation_point()
	_process_movement(next_navigation_point, _get_movement_speed(), delta)
	if _is_stopped_state():
		return

func _on_update_navigation_timer_timeout():
	var aggression_mod : float = 0.5 if aggression_level == 1 else 1.0
	var random_offset : float = clampf(randfn(nav_refresh_rate, 0.5), nav_refresh_rate * 0.5, nav_refresh_rate * 1.5)
	var refresh_after : float = random_offset * aggression_mod
	emit_signal("nav_update_requested")
	$UpdateNavigationTimer.start(refresh_after)
