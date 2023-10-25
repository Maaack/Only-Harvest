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
const EGGPLANT_SEEDS_NAME : String = "Eggplant Seeds"
const WHEAT_SEEDS_NAME : String = "Wheat Seeds"
const MEANERRABBIT_NAME : String = "Meaner Rabbit"
const MCGREGOR_NAME : String = "McGregor"
const JOHANSONSON_NAME : String = "Johansonson"
const MADISONSON_NAME : String = "Madisonson"
const DORATHORY_NAME : String = "Dorathory"
const CREDIT_NAME : String = "Credit"
const CRYPTO_NAME : String = "Darko Crypto"
const TOOL_NAME : String = "Tool"
const PASSIVE_NAME : String = "Passive"
const AXE_NAME : String = "Axe"
const HOE_NAME : String = "Hoe"
const CLOCK_NAME : String = "Time Warp"
const STOLEN_WHEAT_NAME : String = "Stolen Wheat"
const STOLEN_EGGPLANT_NAME : String = "Stolen Eggplant"

const CREDIT_GOAL : int = 100
const CRYPTO_GOAL : int = 1000

const CROP_NAMES : Dictionary = {
	EGGPLANT_NAME : Crops.EGGPLANT,
	WHEAT_NAME : Crops.WHEAT,
}

const CROP_GROWTH_RATES : Dictionary = {
	EGGPLANT_NAME : [24,24,24],
	WHEAT_NAME : [12,12,12],
}

const SEED_NAMES : Array = [
	EGGPLANT_SEEDS_NAME,
	WHEAT_SEEDS_NAME,
]

const HIGHLIGHT_TILE_TOOLS : Array = [
	EGGPLANT_SEEDS_NAME,
	WHEAT_SEEDS_NAME,
	HOE_NAME
]

const EMPTY_LAYERS_FOR_PLANTING : Array = [
	0,
	2,
	3,
	4,
	5,
	6,
	7,
]

const EMPTY_LAYERS_FOR_HOEING : Array = [
	0,
	3,
	4,
	6,
	7,
]

# Hoe higher layers before lower layers
const FILLED_LAYERS_FOR_HOEING : Array = [
	5,
	2,
]

enum TileTool {
	SEEDS,
	HOE,
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
