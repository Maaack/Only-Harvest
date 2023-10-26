extends Node

enum CameraTargets{
	PLAYER,
	GHOST,
	FARM,
	NEIGHBOR,
	COWS,
	MARKET,
	BLACKMARKET,
}

enum Goals{
	CREDITS,
	CRYPTOS
}

var current_camera_target : CameraTargets = CameraTargets.PLAYER
var is_player_dead : bool = false
var player_sleep_duration : int = 0
var randomizer : float
var pending_goals : Array[Goals] = []
var total_goals : int = 0

func reset_game_state():
	is_player_dead = false
	pending_goals = []
	total_goals = 0

func add_credits_goal():
	if reached_max_goals():
		return
	pending_goals.append(Goals.CREDITS)
	total_goals += 1
	
func add_cryptos_goal():
	if reached_max_goals():
		return
	pending_goals.append(Goals.CRYPTOS)
	total_goals += 1

func get_next_pending_goal():
	if pending_goals.size() == 0:
		return null
	return pending_goals.pop_front()

func reached_max_goals():
	return total_goals >= 2

func camera_target_player():
	current_camera_target = CameraTargets.PLAYER

func camera_target_ghost():
	current_camera_target = CameraTargets.GHOST

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
