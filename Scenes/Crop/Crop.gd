extends Area2D
class_name Crop

signal harvested

@export var crop_type : Constants.Crops = Constants.Crops.NONE
@export var growth_stage : Constants.Stages = Constants.Stages.ONE
@export var faction : Constants.Factions = Constants.Factions.NONE

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

func _get_age_for_crop_stage(input_stage : Constants.Stages):
	var age_for_stage : int = 0
	if input_stage > growth_rates.size():
		input_stage = growth_rates.size()
	for iter in range(input_stage):
		age_for_stage += growth_rates[iter]
	return age_for_stage

func _set_crop_age_iter_from_stage():
	raw_crop_age = _get_age_for_crop_stage(growth_stage-1)

func _set_growth_rate_iter_from_age():
	growth_rate_iter = 0
	var total_duration = 0
	for duration in growth_rates:
		total_duration += duration
		if total_duration > raw_crop_age:
			break
		growth_rate_iter += 1

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

func _increment_growth_stage():
	var next_stage : Constants.Stages
	match(growth_stage):
		Constants.Stages.ONE:
			next_stage = Constants.Stages.TWO
		Constants.Stages.TWO:
			next_stage = Constants.Stages.THREE
		Constants.Stages.THREE:
			next_stage = Constants.Stages.FOUR
		Constants.Stages.FOUR:
			next_stage = Constants.Stages.FOUR
	growth_stage = next_stage

func _check_crop_age():
	var total_growth_stage_duration : int = _get_age_for_crop_stage(growth_stage)
	if raw_crop_age >= total_growth_stage_duration:
		_increment_growth_stage()
		_set_growth_rate_iter_from_age()
		_update_growth_stage()

func _ready():
	_update_crop_type()
	_set_crop_age_iter_from_stage()
	_set_growth_rate_iter_from_age()
	_update_growth_stage()

func increment_crop_age(amount : int = 1):
	raw_crop_age += amount
	_check_crop_age()

func try_harvest():
	if growth_stage == Constants.Stages.FOUR:
		emit_signal("harvested")
		queue_free()
