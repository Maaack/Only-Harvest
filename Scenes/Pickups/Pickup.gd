extends CharacterBody2D
class_name Pickup

signal picked_up

@export var texture : Texture :
	set(value):
		texture = value
		if is_visible_in_tree():
			$Sprite2D.texture = texture
@export var is_draggable : bool = true
@export var friction : float = 300
@export var friction_mod : float = 1
@export_range(0, 1000.0) var bounce_force : float = 100.0

var is_picked_up : bool = false
var is_dragged : bool = false

func _physics_process(delta):
	if not is_dragged:
		velocity = velocity.move_toward(Vector2.ZERO, friction * friction_mod * delta)
		if get_position_delta().length_squared() < 1:
			velocity = Vector2.ZERO
	move_and_slide()

func _process_pickup():
	emit_signal("picked_up")
	queue_free()

func pickup():
	if is_picked_up:
		return
	is_picked_up = true
	_process_pickup()

func bounce_away():
	is_dragged = false
	$AnimationPlayer.play("Bounce")
	var random_angle := randf_range(-2*PI, 2*PI)
	var random_direction := Vector2.from_angle(random_angle)
	velocity += random_direction.normalized() * bounce_force

func _ready():
	texture = texture
	is_draggable = is_draggable
