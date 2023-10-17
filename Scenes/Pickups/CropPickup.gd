@tool
extends Pickup

const WHEAT_FRAME = 5
const EGGPLANT_FRAME = 11

@export var crop_type : Constants.Crops = Constants.Crops.NONE :
	set(value):
		crop_type = value
		if is_visible_in_tree():
			match(crop_type):
				Constants.Crops.WHEAT:
					$Sprite2D.frame = WHEAT_FRAME
				Constants.Crops.EGGPLANT:
					$Sprite2D.frame = EGGPLANT_FRAME

func _ready():
	crop_type = crop_type
