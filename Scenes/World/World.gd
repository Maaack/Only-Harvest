extends Node2D

signal time_updated

var world_time : int = 0
var hours_in_day : int = 24

func increment_world_time(amount : int = 1):
	world_time += amount
	emit_signal("time_updated")

func _on_timer_timeout():
	increment_world_time()

func get_day():
	return floor(world_time / hours_in_day)

func get_hour():
	return world_time % hours_in_day
