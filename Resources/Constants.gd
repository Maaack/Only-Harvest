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

enum Periods{
	DAY,
	NIGHT,
}

const EGGPLANT_NAME : String = "Eggplant"
const WHEAT_NAME : String = "Wheat"
const MEANERRABBIT_NAME : String = "Meaner Rabbit"
const MCGREGOR_NAME : String = "McGregor"
const JOHANSONSON_NAME : String = "Johansonson"
const MADISONSON_NAME : String = "Madisonson"
const DORATHORY_NAME : String = "Dorathory"
const CREDITS_NAME : String = "Credit"
const CRYPTOS_NAME : String = "Darko Crypto"
const TOOL_NAME : String = "Tool"
const PASSIVE_NAME : String = "Passive"
const AXE_NAME : String = "Axe"
const HOE_NAME : String = "Hoe"
const CLOCK_NAME : String = "Time Warp"

const CROP_NAMES : Dictionary = {
	EGGPLANT_NAME : Crops.EGGPLANT,
	WHEAT_NAME : Crops.WHEAT,
}

const CROP_GROWTH_RATES : Dictionary = {
	EGGPLANT_NAME : [24,24,24],
	WHEAT_NAME : [12,12,12],
}

const FACTION_NAMES : Dictionary = {
	Factions.MEANERRABBIT : MEANERRABBIT_NAME,
	Factions.MCGREGOR : MCGREGOR_NAME,
	Factions.JOHANSONSON : JOHANSONSON_NAME,
	Factions.MADISONSON : MADISONSON_NAME,
	Factions.DORATHORY : DORATHORY_NAME,
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
