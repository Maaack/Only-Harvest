extends Control

func _on_world_time_updated():
	%DateTime.set_day(%World.get_day())
	%DateTime.set_hour(%World.get_hour())


func _on_world_quickslots_updated(slot_array):
	%Quickslots.update_quickslots(slot_array)


func _on_world_player_started_trespassing(faction):
	if faction not in Constants.FACTION_NAMES:
		return
	var owner_name = Constants.FACTION_NAMES[faction]
	%TrespassingWarning.text = "You are trespassing on %s's property!" % owner_name
	%TrespassingWarning.show()

func _on_world_player_stopped_trespassing(faction):
	%TrespassingWarning.hide()
