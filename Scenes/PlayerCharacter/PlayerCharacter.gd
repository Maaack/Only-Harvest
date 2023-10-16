extends CharacterBody2D
class_name PlayerCharacter

signal jump
signal item_equipped(item_name : String)
signal item_received(item_name : String)
signal health_changed(health : float, max_health : float)
signal died

@export var max_health : float = 10
@export var health_per_heart : float = 2
@export var acceleration : float = 600
@export var max_speed : float = 7500
@export var friction : float = 600
@export var current_weapon_iter : int = 0

@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_tree = %CharacterAnimationTree
@onready var animation_state : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var facing_direction : Vector2
var can_jump : bool = true
var is_jumping : bool = false
var can_take_damage : bool = true
var health : float = max_health
var accessible_interactables : Array = []

func pickup_item(_item):
	pass

func cycle_next():
	pass

func cycle_prev():
	pass

func get_current_item():
	pass

func face_direction(new_direction : Vector2):
	facing_direction = new_direction.normalized()
	# var facing_angle = facing_direction.angle()
	animation_tree.set("parameters/Idle/blend_position", facing_direction)
	animation_tree.set("parameters/Walk/blend_position", facing_direction)
	animation_tree.set("parameters/Jump/blend_position", facing_direction)


func start_jump():
	set_collision_mask_value(1, false)
	animation_state.travel("Jump")
	can_jump = false
	emit_signal("jump")

func finish_jump():
	set_collision_mask_value(1, true)
	can_jump = true
	is_jumping = false

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	if is_jumping and can_jump:
		start_jump()
	if is_jumping:
		pass
	elif input_vector != Vector2.ZERO:
		face_direction(input_vector)
		velocity = velocity.move_toward(input_vector * max_speed * delta, acceleration * delta)
		animation_state.travel("Walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		animation_state.travel("Idle")
	move_and_slide()

func _physics_process(delta):
	move_state(delta)

func _apply_personal_knockback():
	for body in $KnockbackArea2D.get_overlapping_bodies():
		##if body.is_in_group(TeamConstants.ENEMY_GROUP):
		if body.has_method("knockback"):
			body.knockback(position, 150)
		if body.has_method("stun"):
			body.stun(0.75, true)

func start_death():
	pass

func _take_damage():
	can_take_damage = false
	$DamageAnimationPlayer.play("damage_blink")
	$HitStreamPlayer2D.play()
	_apply_personal_knockback()
	emit_signal("health_changed", health, max_health)

func _hit(damage : int):
	if can_take_damage:
		health -= damage
		if health <= 0:
			health = 0
			start_death()
			emit_signal("health_changed", health, max_health)
		else:
			_take_damage()

func hit_heart(heart_damage : float = 1.0):
	var total_damage : int = floor(heart_damage * health_per_heart)
	_hit(total_damage)

func is_health_full():
	return health >= max_health 

func recover(add_health, temp_invulnerability : bool = false):
	health += add_health 
	if health > max_health:
		_set_health_to_max()
	if temp_invulnerability:
		can_take_damage = false
		$DamageAnimationPlayer.play("damage_blink")
	emit_signal("health_changed", health, max_health)

func recover_heart(add_hearts : float = 1.0, temp_invulnerability : bool = false):
	var total_extra_health : float = add_hearts * health_per_heart
	recover(total_extra_health, temp_invulnerability)

func _set_health_to_max():
	health = max_health

func _ready():
	await get_tree().create_timer(0.05).timeout
	_set_health_to_max()

func _input(event):
	if event.is_action_pressed("jump"):
		is_jumping = true
