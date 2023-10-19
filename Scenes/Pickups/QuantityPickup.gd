extends Pickup
class_name QuantityPickup

@export var quantity : BaseQuantity : 
	set(value):
		quantity = value
		if is_visible_in_tree():
			$Sprite2D.texture = quantity.icon

func _ready():
	quantity = quantity
