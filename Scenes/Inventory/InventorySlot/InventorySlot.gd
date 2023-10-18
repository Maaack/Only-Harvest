@tool
extends Control

@onready var texture_node = %TextureRect
@onready var count_node = %Count

@export var quantity : BaseQuantity :
	set = set_quantity

func _process(_delta):
	_update_quantity()

func set_quantity(value:BaseQuantity):
	quantity = value
	_update_quantity()

func _update_quantity():
	if is_instance_valid(quantity) and quantity is BaseQuantity:
		texture_node.texture = quantity.icon
		count_node.text = str(quantity.quantity)
	else:
		texture_node.texture = null
		count_node.text = ""
