extends Area2D

@export var crop : Constants.Crops = Constants.Crops.NONE
@export var growth_stage : Constants.Stages = Constants.Stages.ONE

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_state : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
var crop_stage_animation_state = null
var crop_state_name : String = ""

func _set_type_state():
	match(crop):
		Constants.Crops.WHEAT:
			crop_state_name = "Wheat"
		Constants.Crops.EGGPLANT:
			crop_state_name = "Eggplant"
	var animation_playback_name : String = "parameters/%s/playback" % crop_state_name
	crop_stage_animation_state = animation_tree.get(animation_playback_name)
	animation_state.travel(crop_state_name)

func _set_growth_state():
	if crop_stage_animation_state == null:
		return
	match(growth_stage):
		Constants.Stages.ONE:
			pass
		Constants.Stages.TWO:
			crop_stage_animation_state.travel(crop_state_name + "2")
		Constants.Stages.THREE:
			crop_stage_animation_state.travel(crop_state_name + "3")
		Constants.Stages.FOUR:
			crop_stage_animation_state.travel(crop_state_name + "4")

func _ready():
	_set_type_state()
	_set_growth_state()
	
