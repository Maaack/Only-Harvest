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
