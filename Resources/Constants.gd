extends Object
class_name Constants

enum Crops{
	NONE = -1,
	EGGPLANT,
	WHEAT,
}
enum Stages{
	ZERO,
	ONE,
	TWO,
	THREE,
	FOUR,
}

const EGGPLANT_NAME : String = "Eggplant"
const WHEAT_NAME : String = "Wheat"

const CROP_GROWTH_RATES : Dictionary = {
	EGGPLANT_NAME : [6,6,6],
	WHEAT_NAME : [3,3,3],
}

static func get_crop_tilemap():
	return {
		Vector2i(1, 0) : CropStage.new(Crops.WHEAT, Stages.ONE),
		Vector2i(2, 0) : CropStage.new(Crops.WHEAT, Stages.TWO),
		Vector2i(3, 0) : CropStage.new(Crops.WHEAT, Stages.THREE),
		Vector2i(4, 0) : CropStage.new(Crops.WHEAT, Stages.FOUR),
		Vector2i(1, 1) : CropStage.new(Crops.EGGPLANT, Stages.ONE),
		Vector2i(2, 1) : CropStage.new(Crops.EGGPLANT, Stages.TWO),
		Vector2i(3, 1) : CropStage.new(Crops.EGGPLANT, Stages.THREE),
		Vector2i(4, 1) : CropStage.new(Crops.EGGPLANT, Stages.FOUR),
	}
