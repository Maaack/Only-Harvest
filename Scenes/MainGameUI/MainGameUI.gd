extends Control

func _on_world_time_updated():
	%DateTime.set_day(%World.get_day())
	%DateTime.set_hour(%World.get_hour())
