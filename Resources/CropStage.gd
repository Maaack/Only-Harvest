extends Resource
class_name CropStage

@export var type : Constants.Crops = Constants.Crops.NONE
@export var stage : Constants.Stages = Constants.Stages.ZERO

func _init(new_type : Constants.Crops, new_stage : Constants.Stages):
	type = new_type
	stage = new_stage
