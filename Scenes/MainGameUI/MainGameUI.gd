extends Control

func _on_world_time_updated():
	%DateTime.set_day(%World.get_day())
	var hour = %World.get_hour()
	%DateTime.set_hour(hour)
	if hour > 6 and hour < 18:
		%DateTime.set_mode(0)
	else:
		%DateTime.set_mode(1)

func _update_goal_meter(slot_array):
	for slot in slot_array:
		if slot is BaseQuantity and is_instance_valid(slot):
			if slot.name == Constants.CREDIT_NAME:
				%CreditGoal.text = "%d/%d" % [slot.quantity, Constants.CREDIT_GOAL]
			elif slot is BaseQuantity and slot.name == Constants.CRYPTO_NAME:
				%CryptoGoal.text = "%d/%d" % [slot.quantity, Constants.CRYPTO_GOAL]

func _on_world_quickslots_updated(slot_array):
	%Quickslots.update_quickslots(slot_array)
	_update_goal_meter(slot_array)

func _on_world_player_started_trespassing(faction):
	if faction not in Constants.FACTION_NAMES:
		return
	var owner_name = Constants.FACTION_NAMES[faction]
	%TrespassingWarning.text = "You are trespassing on %s's property!" % owner_name
	%TrespassingBox.show()

func _on_world_player_stopped_trespassing(faction):
	%TrespassingBox.hide()

func _on_world_game_ended(days_passed, quantities):
	get_tree().paused = true
	$Transition.close()
	await($Transition.transition_finished)
	$MarginContainer.hide()
	$GameOver.show()
	$GameOver.days_passed = days_passed
	$GameOver.earnings = quantities
	$GameOver.refresh_text()

func _on_world_trading_offered(buying, selling, can_buy):
	%TradePanel.show()
	%BuyingSlot.quantity = buying
	%SellingSlot.quantity = selling
	%TradeDisabledTexture.visible = not can_buy

func _on_world_trading_revoked():
	%TradePanel.hide()

func _on_world_dialogue_offered(action_name):
	%DialoguePanel.show()
	%ActionName.text = action_name

func _on_world_dialogue_revoked():
	%DialoguePanel.hide()

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
	GameState.randomizer = randf()
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/MainStory.dialogue"), title)
	get_tree().paused = true
	await(DialogueManager.dialogue_ended)
	GameState.camera_target_player()
	get_tree().paused = false
	if GameState.is_player_dead:
		%World.kill_player()
	if GameState.player_sleep_duration > 0:
		%World.hold_player()
		%World.pass_world_time(GameState.player_sleep_duration)
		$Transition.close()
		await($Transition.transition_finished)
		$Transition.open()
		await($Transition.transition_finished)
		GameState.player_sleep_duration = 0
		%World.release_player()
