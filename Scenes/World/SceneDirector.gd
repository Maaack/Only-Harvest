extends Node
class_name SceneDirector

const CAMERA_LOCK_DISTANCE : float = 32

@export var player_character : Node2D
@export var scene_camera : Camera2D
@export var family_farm_marker : Marker2D
@export var neighbor_farm_marker : Marker2D
@export var cow_marker : Marker2D

var current_target : Vector2
var is_panning : bool = false

func _pan_camera_to_target():
	if is_panning:
		return
	is_panning = true
	var tween = create_tween()
	tween.tween_property(scene_camera, "position", current_target, 0.25)
	await(tween.finished)
	is_panning = false

func _update_camera_position():
	match(GameState.current_camera_target):
		GameState.CameraTargets.PLAYER:
			current_target = player_character.position
		GameState.CameraTargets.FARM:
			current_target = family_farm_marker.position
		GameState.CameraTargets.NEIGHBOR:
			current_target = neighbor_farm_marker.position
		GameState.CameraTargets.COWS:
			current_target = cow_marker.position
	if scene_camera.position.distance_squared_to(current_target) > pow(CAMERA_LOCK_DISTANCE, 2) :
		_pan_camera_to_target()
	else:
		scene_camera.position = current_target

func _process(delta):
	_update_camera_position()
