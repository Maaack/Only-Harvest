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

func _on_world_game_ended(days_passed, quantities):
	get_tree().paused = true
	$Transition.close()
	await($Transition.transition_finished)
	$MarginContainer.hide()
	$GameOver.show()
	$GameOver.days_passed = days_passed
	$GameOver.earnings = quantities
	$GameOver.refresh_text()

func _on_world_trading_offered(buying, selling):
	%TradePanel.show()
	%BuyingSlot.quantity = buying
	%SellingSlot.quantity = selling

func _on_world_trading_revoked():
	%TradePanel.hide()

func _on_world_quickslot_selected(slot):
	%Quickslots.select_slot(slot)

func _player_died():
	get_tree().paused = true
	$Transition.close()
	await($Transition.transition_finished)
	get_tree().paused = false
	%World.pass_world_time(24, 0.05)
	await(%World.time_passed)
	%World.respawn_player()
	GameState.player_respawned()

func _on_world_player_died():
	GameState.player_died()
	_player_died()

func _on_world_player_spawned():
	$Transition.open()

func _on_world_dialogue_started(title : String):
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/MainStory.dialogue"), title)
	get_tree().paused = true
	await(DialogueManager.dialogue_ended)
	get_tree().paused = false
	GameState.camera_target_player()
	if GameState.is_player_dead:
		%World.kill_player()
