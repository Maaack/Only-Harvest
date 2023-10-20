extends Object
class_name Constants

enum Crops{
	NONE = -1,
	EGGPLANT,
	WHEAT,
}

enum Monies{
	NONE = -1,
	CREDITS,
	CRYPTOS,
}

enum Stages{
	ZERO,
	ONE,
	TWO,
	THREE,
	FOUR,
}

enum Factions{
	NONE = -1,
	PLAYER,
	MCGREGOR,
	JOHANSONSON,
	MADISONSON,
	MCFICKLEFECKER,
	DORATHORY,
	FEELBAGGINS,
	MEANERRABBIT,
}

const EGGPLANT_NAME : String = "Eggplant"
const WHEAT_NAME : String = "Wheat"
const MEANERRABBIT_NAME :String = "Meaner Rabbit"
const MCGREGOR_NAME :String = "McGregor"

const CROP_NAMES : Dictionary = {
	EGGPLANT_NAME : Crops.EGGPLANT,
	WHEAT_NAME : Crops.WHEAT,
}

const CROP_GROWTH_RATES : Dictionary = {
	EGGPLANT_NAME : [6,6,6],
	WHEAT_NAME : [3,3,3],
}

const FACTION_NAMES : Dictionary = {
	Factions.MEANERRABBIT : MEANERRABBIT_NAME,
	Factions.MCGREGOR : MCGREGOR_NAME
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
