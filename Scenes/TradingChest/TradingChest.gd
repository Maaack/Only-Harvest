extends Node2D
class_name TradingChest

signal dropped(quantity : BaseQuantity)

@export var buying : BaseQuantity
@export var selling : BaseQuantity
@export var selling_chunk_size : int = 1

var sell_amount_processing : int = 0

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		$AnimationPlayer.play("Opening")
		$OpenStreamPlayer2D.play()
		body.offer_trade(self)

func _on_area_2d_body_exited(body):
	if body is PlayerCharacter:
		$AnimationPlayer.play_backwards("Opening")
		body.revoke_trade()

func _physics_process(delta):
	if sell_amount_processing > 0:
		var selling_one : BaseQuantity = selling.duplicate()
		var chunk_size : int = min(selling_chunk_size, sell_amount_processing)
		selling_one.quantity = chunk_size
		emit_signal("dropped", selling_one)
		sell_amount_processing -= chunk_size

func trade(trading : BaseQuantity):
	if trading.name == buying.name and trading.quantity >= buying.quantity:
		sell_amount_processing += selling.quantity
	$Area2D.monitoring = false
	await(get_tree().create_timer(0.1, false).timeout)
	$Area2D.monitoring = true
