extends Node2D
class_name TradingChest

signal dropped(quantity : BaseQuantity)

@export var buying : BaseQuantity
@export var selling : BaseQuantity

var sell_amount_processing : int = 0

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		$AnimationPlayer.play("Opening")
		sell_amount_processing += selling.quantity

func _on_area_2d_body_exited(body):
	if body is PlayerCharacter:
		$AnimationPlayer.play_backwards("Opening")

func _physics_process(delta):
	if sell_amount_processing > 0:
		var selling_one : BaseQuantity = selling.duplicate()
		selling_one.quantity = 1
		emit_signal("dropped", selling_one)
		sell_amount_processing -= 1
