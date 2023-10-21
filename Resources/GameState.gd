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
var is_player_dead : bool = false
var player_sleep_duration : int = 0
var randomizer : float

func camera_target_player():
	current_camera_target = CameraTargets.PLAYER

func camera_target_farm():
	current_camera_target = CameraTargets.FARM

func camera_target_neighbor():
	current_camera_target = CameraTargets.NEIGHBOR

func camera_target_cows():
	current_camera_target = CameraTargets.COWS

func player_died():
	is_player_dead = true

func player_respawned():
	is_player_dead = false

func player_slept():
	player_sleep_duration = 8
