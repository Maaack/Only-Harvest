extends Area2D
class_name Crop

@export var crop_type : Constants.Crops = Constants.Crops.NONE
@export var growth_stage : Constants.Stages = Constants.Stages.ONE

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_state : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
var crop_stage_animation_state = null
var crop_type_name : String = ""
var growth_rates : Array = []
var growth_rate_iter : int = 0
var raw_crop_age : int = 0

func _update_crop_type():
	match(crop_type):
		Constants.Crops.WHEAT:
			crop_type_name = Constants.WHEAT_NAME
		Constants.Crops.EGGPLANT:
			crop_type_name = Constants.EGGPLANT_NAME
	if crop_type_name == null or crop_type_name == "":
		return
	var animation_playback_name : String = "parameters/%s/playback" % crop_type_name
	crop_stage_animation_state = animation_tree.get(animation_playback_name)
	animation_state.travel(crop_type_name)
	growth_rates = Constants.CROP_GROWTH_RATES[crop_type_name]

func _set_growth_rate_iter_from_stage():
	match(growth_stage):
		Constants.Stages.ONE:
			growth_rate_iter = 0
		Constants.Stages.TWO:
			growth_rate_iter = 1
		Constants.Stages.THREE:
			growth_rate_iter = 2

func _update_growth_stage():
	if crop_stage_animation_state == null:
		return
	match(growth_stage):
		Constants.Stages.ONE:
			pass
		Constants.Stages.TWO:
			crop_stage_animation_state.travel(crop_type_name + "2")
		Constants.Stages.THREE:
			crop_stage_animation_state.travel(crop_type_name + "3")
		Constants.Stages.FOUR:
			crop_stage_animation_state.travel(crop_type_name + "4")

func _check_crop_age():
	var total_growth_stage_duration : int = 0
	for iter in range(growth_rate_iter + 1):
		total_growth_stage_duration += growth_rates[iter]
	if raw_crop_age > 0 and raw_crop_age % total_growth_stage_duration == 0:
		growth_stage += Constants.Stages.ONE
		_update_growth_stage()

func _ready():
	_update_crop_type()
	_set_growth_rate_iter_from_stage()
	_update_growth_stage()

func increment_crop_age(amount : int = 1):
	raw_crop_age += amount
	_check_crop_age()
