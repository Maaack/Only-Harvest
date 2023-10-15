extends Area2D

@export var crop : Constants.Crops = Constants.Crops.NONE

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation_state : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
var crop_stage_animation_state = null

func _ready():
	match(crop):
		Constants.Crops.WHEAT:
			animation_state.travel("Wheat")
			crop_stage_animation_state = animation_tree.get("parameters/Wheat/playback")
		Constants.Crops.EGGPLANT:
			animation_state.travel("Eggplant")
			crop_stage_animation_state = animation_tree.get("parameters/Eggplant/playback")
