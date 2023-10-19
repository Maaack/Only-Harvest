@tool
extends Area2D
class_name PrivateProperty

signal player_started_trespassing(owner : Constants.Factions)
signal player_stopped_trespassing(owner : Constants.Factions)

@export var faction : Constants.Factions

func _on_body_entered(body):
	if body is PlayerCharacter and faction != Constants.Factions.PLAYER:
		emit_signal("player_started_trespassing", faction)
	elif body is GuardDog and body.faction == Constants.Factions.NONE:
		body.faction = faction

func _on_body_exited(body):
	if body is PlayerCharacter and faction != Constants.Factions.PLAYER:
		emit_signal("player_stopped_trespassing", faction)

func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area is Crop:
		area.faction = faction
