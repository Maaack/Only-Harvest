extends Pickup
class_name MoneyPickup

var item : BaseQuantity

@export var money_type : Constants.Monies = Constants.Monies.NONE :
	set(value):
		money_type = value
		if is_visible_in_tree():
			match(money_type):
				Constants.Monies.CREDITS:
					item = load("res://Resources/Items/Credit.tres")
				Constants.Monies.CRYPTOS:
					item = load("res://Resources/Items/DarkoCrypto.tres")
			$Sprite2D.texture = item.icon

func _ready():
	money_type = money_type
