@tool
extends Pickup
class_name CropPickup

const WHEAT_FRAME = 5
const EGGPLANT_FRAME = 11

var item : BaseQuantity

@export var crop_type : Constants.Crops = Constants.Crops.NONE :
	set(value):
		crop_type = value
		if is_visible_in_tree():
			match(crop_type):
				Constants.Crops.WHEAT:
					$Sprite2D.frame = WHEAT_FRAME
					item = load("res://Resources/Items/HarvestedWheat.tres")
				Constants.Crops.EGGPLANT:
					$Sprite2D.frame = EGGPLANT_FRAME
					item = load("res://Resources/Items/HarvestedEggplant.tres")

func _ready():
	crop_type = crop_type
