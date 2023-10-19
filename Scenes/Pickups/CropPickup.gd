@tool
extends Pickup
class_name CropPickup

var item : BaseQuantity

@export var crop_type : Constants.Crops = Constants.Crops.NONE :
	set(value):
		crop_type = value
		if is_visible_in_tree():
			match(crop_type):
				Constants.Crops.WHEAT:
					item = load("res://Resources/Items/HarvestedWheat.tres")
				Constants.Crops.EGGPLANT:
					item = load("res://Resources/Items/HarvestedEggplant.tres")
			$Sprite2D.texture = item.icon

func _ready():
	crop_type = crop_type
