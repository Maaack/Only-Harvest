extends Node

enum CameraTargets{
	PLAYER,
	FARM,
	NEIGHBOR,
	COWS,
	MARKET,
	BLACKMARKET,
}

var current_camera_target : CameraTargets = CameraTargets.PLAYER

func camera_target_player():
	current_camera_target = CameraTargets.PLAYER

func camera_target_farm():
	current_camera_target = CameraTargets.FARM

func camera_target_neighbor():
	current_camera_target = CameraTargets.NEIGHBOR

func camera_target_cows():
	current_camera_target = CameraTargets.COWS

