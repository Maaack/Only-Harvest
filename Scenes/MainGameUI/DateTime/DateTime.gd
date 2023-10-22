extends NinePatchRect

func set_day(day : int):
	pass
	$VBox/Day.text = "Day %d" % (day + 1)

func set_hour(hour : int):
	$VBox/Time.text = "%02d:00" % hour

func set_mode(new_mode : int):
	match(new_mode):
		0:
			region_rect = Rect2i(201,9,30,30)
		1:
			region_rect = Rect2i(201,57,30,30)
