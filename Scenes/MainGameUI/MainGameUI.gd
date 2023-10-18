extends Control

func _on_world_time_updated():
	%DateTime.set_day(%World.get_day())
	%DateTime.set_hour(%World.get_hour())


func _on_world_quickslots_updated(slot_array):
	%Quickslots.update_quickslots(slot_array)
